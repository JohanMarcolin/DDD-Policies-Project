import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'users_view/blocs/users_view_bloc/users_view_bloc.dart';
import '../../infrastructure/models/user.dart';
import 'users_view/components/user_tile.dart';

class WorkspaceScreen extends StatelessWidget {
  const WorkspaceScreen({super.key});

  Future<void> _showUpdateDialog(
    BuildContext context,
    String title,
    String label,
    Function(String) onUpdate,
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
            child: const Text('Update'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      onUpdate(result);
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
            return Center(child: Text(state.message));
          }
          if (state is UsersViewLoaded) {
            return ListView.builder(
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                return UserTile(
                  user: user,
                  onRemove: () => context.read<UsersViewBloc>().add(
                    UserRemoveRequested(user.id),
                  ),
                  onUpdateEmail: () => _showUpdateDialog(
                    context,
                    'Update Email',
                    'New Email',
                    (newEmail) => context.read<UsersViewBloc>().add(
                      UserUpdateEmailRequested(user.id, newEmail),
                    ),
                  ),
                  onUpdatePassword: () => _showUpdateDialog(
                    context,
                    'Update Password',
                    'New Password',
                    (newPassword) => context.read<UsersViewBloc>().add(
                      UserUpdatePasswordRequested(user.id, newPassword),
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
