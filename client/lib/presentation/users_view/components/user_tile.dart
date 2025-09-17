import 'package:flutter/material.dart';
import '../../../infrastructure/models/user.dart';

class UserTile extends StatelessWidget {
  final User user;
  final VoidCallback onRemove;
  final VoidCallback onUpdateEmail;
  final VoidCallback onUpdatePassword;
  const UserTile({
    super.key,
    required this.user,
    required this.onRemove,
    required this.onUpdateEmail,
    required this.onUpdatePassword,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(user.username),
      subtitle: Text(user.email),
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
            tooltip: 'Remove User',
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
