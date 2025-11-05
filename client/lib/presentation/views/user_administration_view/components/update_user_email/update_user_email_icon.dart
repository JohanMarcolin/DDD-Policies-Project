part of '../../user_administration_view.dart';

class UpdateUserEmailIcon extends StatelessWidget {
  const UpdateUserEmailIcon({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<UserAdministrationViewBloc>();
    final updateEmail = bloc.authorizeUpdateEmail(user);

    return UserActionIcon<
      UpdateUserEmailSuccess,
      UpdateUserEmailUnauthorizedReason
    >(
      icon: Icons.email,
      isActionAuthorized: updateEmail is Authorized,
      dialogChildBuilder: (context, {required closeDialog}) =>
          UpdateUserEmailDialogChild(
            isUserUpdatingSelf: bloc.isAdministratingSelf(user),
            onCancel: () async => await closeDialog(context),
            onConfirm: (value) {
              bloc.add(
                UpdateUserEmailRequested(
                  targetUser: user,
                  newEmail: Email(value),
                ),
              );
            },
          ),
      eventMessageMapper: (event) => switch (event) {
        UpdateUserEmailInvalid() => 'Invalid email format',
        UpdateUserEmailFailure() => 'Failed to update email',
        UpdateUserEmailSuccess() => 'Email updated successfully',
        _ => '',
      },
      unauthorizedReason: updateEmail is Unauthorized
          ? updateEmail.reason as UpdateUserEmailUnauthorizedReason
          : null,
      unauthorizedMessageMapper: (reason) => switch (reason) {
        CannotUpdateEmailOnAnalyst() =>
          'You cannot update the email of an analyst.',
        CanOnlyUpdateEmailOnSelf() => 'You can only update your own email.',
      },
    );
  }
}
