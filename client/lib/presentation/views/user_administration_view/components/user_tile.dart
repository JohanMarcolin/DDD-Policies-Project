import 'package:client/presentation/views/user_administration_view/blocs/users_view_bloc/user_administration_view_bloc.dart';
import 'package:client/presentation/widgets/confirm_dialog.dart';
import 'package:client/presentation/widgets/action_icon.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:domain/policies/action_policies/action_policy_permission.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserTile extends StatelessWidget {
  const UserTile({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserAdministrationViewBloc, UserAdministrationViewState>(
      builder: (context, state) {
        final bloc = context.read<UserAdministrationViewBloc>();
        final deletePermission = bloc.deleteUserPermission(user);
        final updateEmailPermission = bloc.updateEmailPermission(user);
        final updatePasswordPermission = bloc.updatePasswordPermission(user);

        return ListTile(
          title: Text(user.role.name),
          subtitle: Text(user.email.value),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ActionIcon(
                icon: Icons.email,
                isCrossedOut: !updateEmailPermission.isGranted,
                onPressed: _onUpdateEmail(context, updateEmailPermission, user),
              ),
              ActionIcon(
                icon: Icons.lock,
                isCrossedOut: !updatePasswordPermission.isGranted,
                onPressed: _onUpdatePassword(
                  context,
                  updatePasswordPermission,
                  user,
                ),
              ),
              ActionIcon(
                icon: Icons.delete,
                isCrossedOut: !deletePermission.isGranted,
                onPressed: _onDelete(context, deletePermission, user),
              ),
            ],
          ),
        );
      },
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
        final deniedMsg = switch (reason) {
          CannotDeleteSelf() => 'You cannot delete yourself.',
          CannotDeleteAnalyst() => 'You cannot delete an analyst.',
          CanOnlyDeleteSelf() => 'You can only delete your own account.',
        };
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(deniedMsg)));
        break;
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
        break;
      case Denied(:final reason as UpdateUserEmailDeniedReason):
        final deniedMsg = switch (reason) {
          CannotUpdateEmailOnAnalyst() =>
            'You cannot update the email of an analyst.',
          CanOnlyUpdateEmailOnSelf() => 'You can only update your own email.',
        };
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(deniedMsg)));
        break;
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
          onConfirm: (value) => context.read<UserAdministrationViewBloc>().add(
            UserUpdatePasswordRequested(
              targetUser: user,
              newPassword: Password(value),
            ),
          ),
        );
        break;
      case Denied(:final reason as UpdateUserPasswordDeniedReason):
        final deniedMsg = switch (reason) {
          CannotUpdatePasswordOnAnalyst() =>
            'You cannot update the password of an analyst.',
          CanOnlyUpdatePasswordOnSelf() =>
            'You can only update your own password.',
        };
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(deniedMsg)));
        break;
    }
  };
}
