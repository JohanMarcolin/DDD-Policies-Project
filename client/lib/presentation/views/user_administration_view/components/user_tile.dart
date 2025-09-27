import 'package:client/presentation/views/user_administration_view/components/delete_user_icon.dart';
import 'package:client/presentation/views/user_administration_view/components/update_user_email_icon.dart';
import 'package:client/presentation/views/user_administration_view/components/update_user_password_icon.dart';
import 'package:domain/entities/user.dart';
import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  const UserTile({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(user.role.name),
      subtitle: Text(user.email.value),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          UpdateUserEmailIcon(user: user),
          UpdateUserPasswordIcon(user: user),
          DeleteUserIcon(user: user),
        ],
      ),
    );
  }
}
