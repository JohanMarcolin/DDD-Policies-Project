import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:client/presentation/widgets/action_snack_bar_helper.dart';
import 'package:client/presentation/views/user_administration_view/blocs/users_view_bloc/user_administration_view_bloc.dart';
import 'package:client/presentation/widgets/action_dialog_helper.dart';
import 'package:client/presentation/widgets/action_icon.dart';
import 'package:client/presentation/widgets/confirm_input_dialog.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:domain/policies/action_policies/action_policy_permission.dart';
import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:domain/value_objects/password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpdateUserPasswordIcon extends StatelessWidget {
  const UpdateUserPasswordIcon({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserAdministrationViewBloc, UserAdministrationViewState>(
      builder: (context, state) {
        final bloc = context.read<UserAdministrationViewBloc>();
        final updatePasswordPermission = bloc.updatePasswordPermission(user);

        return ActionIcon(
          icon: Icons.password,
          isGreyedOut: updatePasswordPermission is Denied,
          onPressed: () {
            switch (updatePasswordPermission) {
              case Granted():
                ActionDialogHelper.show(
                  child: BlocProvider.value(
                    value: bloc,
                    child:
                        BlocPresentationListener<
                          UserAdministrationViewBloc,
                          UserAdministrationViewEvent
                        >(
                          listener: (_, event) async {
                            ActionSnackBarHelper.show(
                              context: context,
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
                              ActionDialogHelper.hide();
                            }
                          },
                          child: ConfirmInputDialog(
                            title: 'Update Password',
                            label: 'New Password',
                            isTextObscured: true,
                            onCancel: () => ActionDialogHelper.hide(),
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
              case Denied(:final reason as UpdateUserPasswordDeniedReason):
                ActionSnackBarHelper.show(
                  context: context,
                  message: switch (reason) {
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
