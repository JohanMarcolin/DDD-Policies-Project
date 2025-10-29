part of '../../user_administration_view.dart';

class UpdateUserEmailIcon extends StatelessWidget {
  const UpdateUserEmailIcon({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserAdministrationViewBloc, UserAdministrationViewState>(
      builder: (context, state) {
        final updateEmail = context
            .read<UserAdministrationViewBloc>()
            .authorizeUpdateEmail(user);

        return ActionIcon(
          icon: Icons.email,
          isGreyedOut: updateEmail is Unauthorized,
          onPressed: () {
            switch (updateEmail) {
              case Authorized():
                _showUpdateDialog(context);
              case Unauthorized(
                :final reason as UpdateUserEmailUnauthorizedReason,
              ):
                _showUpdateDeniedSnackBar(context, reason);
            }
          },
        );
      },
    );
  }

  void _showUpdateDialog(BuildContext context) {
    ActionDialogHelper.show(
      context: context,
      child: BlocProvider.value(
        value: context.read<UserAdministrationViewBloc>(),
        child: _buildUpdateDialogContent(context),
      ),
    );
  }

  Widget _buildUpdateDialogContent(BuildContext context) {
    return BlocPresentationListener<
      UserAdministrationViewBloc,
      UserAdministrationViewEvent
    >(
      listener: (_, event) async => _handleUpdateDialogEvent(context, event),
      child: UpdateUserEmailDialogChild(
        onCancel: () async => await ActionDialogHelper.hide(context),
        onConfirm: (value) {
          context.read<UserAdministrationViewBloc>().add(
            UpdateUserEmailRequested(targetUser: user, newEmail: Email(value)),
          );
        },
      ),
    );
  }

  Future<void> _handleUpdateDialogEvent(
    BuildContext context,
    UserAdministrationViewEvent event,
  ) async {
    ActionSnackBarHelper.show(
      message: switch (event) {
        UpdateUserEmailInvalid() => 'Invalid email format',
        UpdateUserEmailFailure() => 'Failed to update email',
        UpdateUserEmailSuccess() => 'Email updated successfully',
        _ => '',
      },
    );
    if (event is UpdateUserEmailSuccess) {
      await ActionDialogHelper.hide(context);
    }
  }

  Future<void> _showUpdateDeniedSnackBar(
    BuildContext context,
    UpdateUserEmailUnauthorizedReason reason,
  ) async {
    ActionSnackBarHelper.show(
      message: switch (reason) {
        CannotUpdateEmailOnAnalyst() =>
          'You cannot update the email of an analyst.',
        CanOnlyUpdateEmailOnSelf() => 'You can only update your own email.',
      },
    );
  }
}
