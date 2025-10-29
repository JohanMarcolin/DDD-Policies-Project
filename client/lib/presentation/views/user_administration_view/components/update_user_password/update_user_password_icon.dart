part of '../../user_administration_view.dart';

class UpdateUserPasswordIcon extends StatelessWidget {
  const UpdateUserPasswordIcon({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserAdministrationViewBloc, UserAdministrationViewState>(
      builder: (context, state) {
        final bloc = context.read<UserAdministrationViewBloc>();
        final updatePassword = bloc.authorizeUpdatePassword(user);

        return ActionIcon(
          icon: Icons.password,
          isGreyedOut: updatePassword is Unauthorized,
          onPressed: () {
            switch (updatePassword) {
              case Authorized():
                ActionDialogHelper.show(
                  context: context,
                  child: BlocProvider.value(
                    value: bloc,
                    child:
                        BlocPresentationListener<
                          UserAdministrationViewBloc,
                          UserAdministrationViewEvent
                        >(
                          listener: (_, event) async {
                            ActionSnackBarHelper.show(
                              message: switch (event) {
                                UpdateUserPasswordInvalid() => switch (event
                                    .reason) {
                                  PasswordTooShort() => 'Password is too short',
                                  PasswordTooLong() => 'Password is too long',
                                  PasswordMissingUppercase() =>
                                    'Password must contain at least one uppercase letter',
                                  PasswordMissingLowercase() =>
                                    'Password must contain at least one lowercase letter',
                                  PasswordMissingNumber() =>
                                    'Password must contain at least one number',
                                  PasswordMissingSpecialCharacter() =>
                                    'Password must contain at least one special character',
                                },
                                UpdateUserPasswordFailure() =>
                                  'Failed to update password',
                                UpdateUserPasswordSuccess() =>
                                  'Password updated successfully',
                                _ => '',
                              },
                            );
                            if (event is UpdateUserPasswordSuccess) {
                              ActionDialogHelper.close(context);
                            }
                          },
                          child: ConfirmInputDialog(
                            title: 'Update Password',
                            label: 'New Password',
                            isTextObscured: true,
                            onCancel: () => ActionDialogHelper.close(context),
                            onConfirm: (value) {
                              bloc.add(
                                UpdateUserPasswordRequested(
                                  targetUser: user,
                                  newPassword: Password(value),
                                ),
                              );
                            },
                          ),
                        ),
                  ),
                );
              case Unauthorized(:final reason):
                ActionSnackBarHelper.show(
                  message: switch (reason
                      as UpdateUserPasswordUnauthorizedReason) {
                    CannotUpdatePasswordOnAnalyst() =>
                      'You cannot update the password of an analyst.',
                    CanOnlyUpdatePasswordOnSelf() =>
                      'You can only update your own password.',
                  },
                );
            }
          },
        );
      },
    );
  }
}
