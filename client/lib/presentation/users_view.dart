import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'users_view/blocs/users_view_bloc/users_view_bloc.dart';
import 'users_view/components/user_tile.dart';
import 'users_view/components/confirm_dialog.dart';
import 'users_view/components/users_app_bar.dart';

class UsersView extends StatelessWidget {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const UsersAppBar(),
      body: BlocBuilder<UsersViewBloc, UsersViewState>(
        builder: (context, state) {
          if (state is UsersViewLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is UsersViewFailure) {
            return Center(child: Text('Failure loading users'));
          }
          if (state is UsersViewLoaded) {
            return ListView.builder(
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                return UserTile(
                  user: user,
                  onDelete: () => ConfirmDialog.show(
                    context,
                    title: "Delete User",
                    label: "Are you sure you want to delete this user?",
                    onConfirm: (_) => context.read<UsersViewBloc>().add(
                      UserDeleteRequested(userId: user.userId),
                    ),
                  ),
                  onUpdateEmail: () => ConfirmDialog.show(
                    context,
                    title: 'Update Email',
                    label: 'New Email',
                    onConfirm: (value) => context.read<UsersViewBloc>().add(
                      UserUpdateEmailRequested(
                        userId: user.userId,
                        newEmail: Email(value),
                      ),
                    ),
                  ),
                  onUpdatePassword: () => ConfirmDialog.show(
                    context,
                    title: 'Update Password',
                    label: 'New Password',
                    onConfirm: (value) => context.read<UsersViewBloc>().add(
                      UserUpdatePasswordRequested(
                        userId: user.userId,
                        newPassword: Password(value),
                      ),
                    ),
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
}
