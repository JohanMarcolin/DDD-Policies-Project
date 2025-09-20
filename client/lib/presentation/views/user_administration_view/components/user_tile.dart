import 'package:domain/entities/user.dart';
import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  const UserTile({
    super.key,
    required this.user,
    required this.onDelete,
    required this.onUpdateEmail,
    required this.onUpdatePassword,
  });

  final User user;
  final VoidCallback? onDelete;
  final VoidCallback? onUpdateEmail;
  final VoidCallback? onUpdatePassword;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(user.role.name),
      subtitle: Text(user.email.value),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.email),
            tooltip: 'Update Email',
            onPressed: onUpdateEmail,
          ),
          IconButton(
            icon: const Icon(Icons.lock),
            tooltip: 'Update Password',
            onPressed: onUpdatePassword,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete User',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
