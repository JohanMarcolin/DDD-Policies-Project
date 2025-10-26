import 'package:client/presentation/views/user_administration_view/components/user_tile.dart';
import 'package:domain/entities/user.dart';
import 'package:flutter/material.dart';

class UserList extends StatelessWidget {
  const UserList({required this.users, super.key});

  final List<User> users;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) => UserTile(user: users[index]),
    );
  }
}
