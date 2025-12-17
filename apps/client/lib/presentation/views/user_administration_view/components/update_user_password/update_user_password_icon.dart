part of '../../user_administration_view.dart';

class UpdateUserPasswordIcon extends StatelessWidget {
  const UpdateUserPasswordIcon({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final icon = Icons.email;
    final bloc = context.read<UserAdministrationViewBloc>();
    final isUserUpdatingSelf = bloc.isAdministratingSelf(user);

    return bloc.authorizeUpdatePassword(
      user,
      onAuthorized: () {
        return UserActionIcon.authorized(
          icon: icon,
          dialogChildBuilder: (context, {required closeDialog}) => UpdateUserPasswordDialogChild(
            isUserUpdatingSelf: isUserUpdatingSelf,
            onCancel: () async => await closeDialog(context),
            onConfirm: (value) {
              bloc.add(UpdateUserPasswordRequested(targetUser: user, newPassword: Password(value)));
            },
          ),
          closeDialogOnEvent: (event) => event is UpdateUserPasswordSuccess,
          eventMessageMapper: (event) => switch (event) {
            UpdateUserPasswordInvalid() => switch (event.reason) {
              PasswordTooShort() => 'Password is too short',
              PasswordTooLong() => 'Password is too long',
              PasswordMissingUppercase() => 'Password must contain at least one uppercase letter',
              PasswordMissingLowercase() => 'Password must contain at least one lowercase letter',
              PasswordMissingNumber() => 'Password must contain at least one number',
              PasswordMissingSpecialCharacter() => 'Password must contain at least one special character',
            },
            UpdateUserPasswordFailure() => 'Failed to update password',
            UpdateUserPasswordSuccess() => 'Password updated successfully',
            _ => '',
          },
        );
      },
      onUnauthorized: (UpdateUserPasswordUnauthorizedReason reason) {
        return UserActionIcon.unauthorized<UpdateUserPasswordUnauthorizedReason>(
          icon: icon,
          unauthorizedReason: reason,
          unauthorizedMessageMapper: (reason) => switch (reason) {
            CannotUpdatePasswordOnAnalyst() => 'You cannot update the password of an analyst',
            CanOnlyUpdatePasswordOnSelf() => 'You can only update your own password',
          },
        );
      },
    );
  }
}
