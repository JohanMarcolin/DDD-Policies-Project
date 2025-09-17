import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'users_view/blocs/users_view_bloc/users_view_bloc.dart';
import 'users_view/components/user_tile.dart';

class UsersView extends StatelessWidget {
  const UsersView({super.key});

  Future<void> _showConfirmDialog(
    BuildContext context,
    String title,
    String label,
    Function(String) onConfirm,
  ) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: label),
          obscureText: label.toLowerCase().contains('password'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      onConfirm(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Administration')),
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
                  onDelete: () => _showConfirmDialog(
                    context,
                    "Delete User",
                    "Are you sure you want to delete this user?",
                    (_) => context.read<UsersViewBloc>().add(
                      UserDeleteRequested(userId: user.userId),
                    ),
                  ),
                  onUpdateEmail: () => _showConfirmDialog(
                    context,
                    'Update Email',
                    'New Email',
                    (value) => context.read<UsersViewBloc>().add(
                      UserUpdateEmailRequested(
                        userId: user.userId,
                        newEmail: Email(value),
                      ),
                    ),
                  ),
                  onUpdatePassword: () => _showConfirmDialog(
                    context,
                    'Update Password',
                    'New Password',
                    (value) => context.read<UsersViewBloc>().add(
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
