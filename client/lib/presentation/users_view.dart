import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:domain/policies/action_policies/action_policy_permission.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'views/user_administration_view/blocs/users_view_bloc/user_administration_view_bloc.dart';
import 'views/user_administration_view/components/user_tile.dart';
import 'widgets/confirm_dialog.dart';
import 'widgets/base_app_bar.dart';

class UserAdministrationView extends StatelessWidget {
  const UserAdministrationView({super.key});

  static const String deleteUserTitle = 'Delete User';
  static const String deleteUserLabel =
      'Are you sure you want to delete this user?';
  static const String deleteUserTooltip = 'Delete User';
  static const String deleteUserCannotDeleteSelf =
      'You cannot delete yourself.';
  static const String deleteUserCannotDeleteAnalyst =
      'You cannot delete an analyst.';
  static const String deleteUserCanOnlyDeleteSelf =
      'You can only delete your own account.';
  static const String deleteUserNotAllowed = 'Not allowed to delete user.';

  static const String updateEmailTitle = 'Update Email';
  static const String updateEmailLabel = 'New Email';
  static const String updateEmailTooltip = 'Update Email';
  static const String updateEmailCannotUpdateAnalyst =
      'You cannot update the email of an analyst.';
  static const String updateEmailCanOnlyUpdateSelf =
      'You can only update your own email.';
  static const String updateEmailNotAllowed = 'Not allowed to update email.';

  static const String updatePasswordTitle = 'Update Password';
  static const String updatePasswordLabel = 'New Password';
  static const String updatePasswordTooltip = 'Update Password';
  static const String updatePasswordCannotUpdateAnalyst =
      'You cannot update the password of an analyst.';
  static const String updatePasswordCanOnlyUpdateSelf =
      'You can only update your own password.';
  static const String updatePasswordNotAllowed =
      'Not allowed to update password.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BaseAppBar(title: 'User Administration'),
      body:
          BlocBuilder<UserAdministrationViewBloc, UserAdministrationViewState>(
            builder: (context, state) {
              if (state is UserAdministrationViewLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is UserAdministrationViewFailure) {
                return Center(child: Text('Failure loading users'));
              }
              if (state is UserAdministrationViewLoaded) {
                return ListView.builder(
                  itemCount: state.users.length,
                  itemBuilder: (context, index) {
                    final user = state.users[index];

                    final bloc = context.read<UserAdministrationViewBloc>();

                    final deletePermission = bloc.deleteUserPermission(user);
                    final updateEmailPermission = bloc.updateEmailPermission(
                      user,
                    );
                    final updatePasswordPermission = bloc
                        .updatePasswordPermission(user);

                    return UserTile(
                      user: user,
                      deleteTooltip: _deleteUserTooltip(deletePermission),
                      onDelete: () =>
                          _onDelete(context, deletePermission, user),
                      updateEmailTooltip: _updateEmailTooltip(
                        updateEmailPermission,
                      ),
                      onUpdateEmail: () =>
                          _onUpdateEmail(context, updateEmailPermission, user),
                      updatePasswordTooltip: _updatePasswordTooltip(
                        updatePasswordPermission,
                      ),
                      onUpdatePassword: () => _onUpdatePassword(
                        context,
                        updatePasswordPermission,
                        user,
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
    );
  }

  String _deleteUserTooltip(ActionPolicyPermission permission) =>
      switch (permission) {
        Granted() => deleteUserTooltip,
        Denied(:final reason as DeleteUserDeniedReason) => switch (reason) {
          CannotDeleteSelf() => deleteUserCannotDeleteSelf,
          CannotDeleteAnalyst() => deleteUserCannotDeleteAnalyst,
          CanOnlyDeleteSelf() => deleteUserCanOnlyDeleteSelf,
        },
      };

  String _updateEmailTooltip(ActionPolicyPermission permission) =>
      switch (permission) {
        Granted() => updateEmailTooltip,
        Denied(:final reason as UpdateUserEmailDeniedReason) =>
          switch (reason) {
            CannotUpdateEmailOnAnalyst() => updateEmailCannotUpdateAnalyst,
            CanOnlyUpdateEmailOnSelf() => updateEmailCanOnlyUpdateSelf,
          },
      };

  String _updatePasswordTooltip(
    ActionPolicyPermission permission,
  ) => switch (permission) {
    Granted() => updatePasswordTooltip,
    Denied(:final reason as UpdateUserPasswordDeniedReason) => switch (reason) {
      CannotUpdatePasswordOnAnalyst() => updatePasswordCannotUpdateAnalyst,
      CanOnlyUpdatePasswordOnSelf() => updatePasswordCanOnlyUpdateSelf,
    },
  };

  VoidCallback? _onDelete(
    BuildContext context,
    ActionPolicyPermission permission,
    User user,
  ) => switch (permission) {
    Granted() => () => ConfirmDialog.show(
      context,
      title: deleteUserTitle,
      label: deleteUserLabel,
      onConfirm: (_) => context.read<UserAdministrationViewBloc>().add(
        UserDeleteRequested(targetUser: user),
      ),
    ),
    Denied() => null,
  };

  VoidCallback? _onUpdateEmail(
    BuildContext context,
    ActionPolicyPermission permission,
    User user,
  ) => switch (permission) {
    Granted() => () => ConfirmDialog.show(
      context,
      title: updateEmailTitle,
      label: updateEmailLabel,
      onConfirm: (value) => context.read<UserAdministrationViewBloc>().add(
        UserUpdateEmailRequested(targetUser: user, newEmail: Email(value)),
      ),
    ),
    Denied() => null,
  };

  VoidCallback? _onUpdatePassword(
    BuildContext context,
    ActionPolicyPermission permission,
    User user,
  ) => switch (permission) {
    Granted() => () => ConfirmDialog.show(
      context,
      title: updatePasswordTitle,
      label: updatePasswordLabel,
      onConfirm: (value) => context.read<UserAdministrationViewBloc>().add(
        UserUpdatePasswordRequested(
          targetUser: user,
          newPassword: Password(value),
        ),
      ),
    ),
    Denied() => null,
  };
}
