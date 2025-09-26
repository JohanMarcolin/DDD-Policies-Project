import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:client/presentation/views/user_administration_view/blocs/users_view_bloc/user_administration_view_bloc.dart';
import 'package:client/presentation/widgets/confirm_dialog.dart';
import 'package:client/presentation/widgets/action_icon.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:domain/policies/action_policies/action_policy_permission.dart';
import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserTile extends StatelessWidget {
  const UserTile({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return BlocPresentationListener<
      UserAdministrationViewBloc,
      UserAdministrationViewEvent
    >(
      listener: (context, event) {
        if (event is UserUpdateEmailInvalid) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(switch (event.reason) {
                  EmailInvalidFormat() => 'Invalid email format',
                }),
              ),
            );
        }
        if (event is UserUpdatePasswordInvalid) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(switch (event.reason) {
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
                }),
              ),
            );
        }
      },
      child:
          BlocBuilder<UserAdministrationViewBloc, UserAdministrationViewState>(
            builder: (context, state) {
              final bloc = context.read<UserAdministrationViewBloc>();
              final deletePermission = bloc.deleteUserPermission(user);
              final updateEmailPermission = bloc.updateEmailPermission(user);
              final updatePasswordPermission = bloc.updatePasswordPermission(
                user,
              );

              return ListTile(
                title: Text(user.role.name),
                subtitle: Text(user.email.value),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ActionIcon(
                      icon: Icons.email,
                      isGreyedOut: !updateEmailPermission.isGranted,
                      onPressed: _onUpdateEmail(
                        context,
                        updateEmailPermission,
                        user,
                      ),
                    ),
                    ActionIcon(
                      icon: Icons.lock,
                      isGreyedOut: !updatePasswordPermission.isGranted,
                      onPressed: _onUpdatePassword(
                        context,
                        updatePasswordPermission,
                        user,
                      ),
                    ),
                    ActionIcon(
                      icon: Icons.delete,
                      isGreyedOut: !deletePermission.isGranted,
                      onPressed: _onDelete(context, deletePermission, user),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }
}

VoidCallback _onDelete(
  BuildContext context,
  ActionPolicyPermission permission,
  User user,
) {
  return () {
    switch (permission) {
      case Granted():
        ConfirmDialog.show(
          context,
          title: 'Delete User',
          label: 'Are you sure you want to delete this user?',
          onConfirm: (_) => context.read<UserAdministrationViewBloc>().add(
            UserDeleteRequested(targetUser: user),
          ),
        );
      case Denied(:final reason as DeleteUserDeniedReason):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(switch (reason) {
              CannotDeleteSelf() => 'You cannot delete yourself.',
              CannotDeleteAnalyst() => 'You cannot delete an analyst.',
              CanOnlyDeleteSelf() => 'You can only delete your own account.',
            }),
          ),
        );
    }
  };
}

VoidCallback _onUpdateEmail(
  BuildContext context,
  ActionPolicyPermission permission,
  User user,
) {
  return () {
    switch (permission) {
      case Granted():
        ConfirmDialog.show(
          context,
          title: 'Update Email',
          label: 'New Email',
          onConfirm: (value) => context.read<UserAdministrationViewBloc>().add(
            UserUpdateEmailRequested(targetUser: user, newEmail: Email(value)),
          ),
        );
      case Denied(:final reason as UpdateUserEmailDeniedReason):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(switch (reason) {
              CannotUpdateEmailOnAnalyst() =>
                'You cannot update the email of an analyst.',
              CanOnlyUpdateEmailOnSelf() =>
                'You can only update your own email.',
            }),
          ),
        );
    }
  };
}

VoidCallback _onUpdatePassword(
  BuildContext context,
  ActionPolicyPermission permission,
  User user,
) {
  return () {
    switch (permission) {
      case Granted():
        ConfirmDialog.show(
          context,
          title: 'Update Password',
          label: 'New Password',
          isTextObscured: true,
          onConfirm: (value) => context.read<UserAdministrationViewBloc>().add(
            UserUpdatePasswordRequested(
              targetUser: user,
              newPassword: Password(value),
            ),
          ),
        );
      case Denied(:final reason as UpdateUserPasswordDeniedReason):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(switch (reason) {
              CannotUpdatePasswordOnAnalyst() =>
                'You cannot update the password of an analyst.',
              CanOnlyUpdatePasswordOnSelf() =>
                'You can only update your own password.',
            }),
          ),
        );
    }
  };
}
