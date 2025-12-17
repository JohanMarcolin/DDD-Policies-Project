part of '../../user_administration_view.dart';

class UpdateUserEmailIcon extends StatelessWidget {
  const UpdateUserEmailIcon({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final icon = Icons.email;
    final bloc = context.read<UserAdministrationViewBloc>();
    final isUserUpdatingSelf = bloc.isAdministratingSelf(user);

    return bloc.authorizeUpdateEmail(
      user,
      onAuthorized: () {
        return UserActionIcon.authorized(
          icon: icon,
          dialogChildBuilder: (context, {required closeDialog}) => UpdateUserEmailDialogChild(
            isUserUpdatingSelf: isUserUpdatingSelf,
            onCancel: () async => await closeDialog(context),
            onConfirm: (value) {
              bloc.add(UpdateUserEmailRequested(targetUser: user, newEmail: Email(value)));
            },
          ),
          closeDialogOnEvent: (event) => event is UpdateUserEmailSuccess,
          eventMessageMapper: (event) => switch (event) {
            UpdateUserEmailInvalid() => 'Invalid email format',
            UpdateUserEmailFailure(:var apiErrorCode) => switch (apiErrorCode) {
              UpdateUserEmailInUseBySelf() => 'This is your current email',
              UpdateUserEmailInUseByOther() => 'This email is already taken',
              _ => 'Failed to update email',
            },
            UpdateUserEmailSuccess() => 'Email updated successfully',
            _ => '',
          },
        );
      },
      onUnauthorized: (UpdateUserEmailUnauthorizedReason reason) {
        return UserActionIcon.unauthorized<UpdateUserEmailUnauthorizedReason>(
          icon: icon,
          unauthorizedReason: reason,
          unauthorizedMessageMapper: (reason) => switch (reason) {
            CannotUpdateEmailOnAnalyst() => 'You cannot update the email of an analyst',
            CanOnlyUpdateEmailOnSelf() => 'You can only update your own email',
          },
        );
      },
    );
  }
}
