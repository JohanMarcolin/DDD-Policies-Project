part of '../user_administration_view.dart';

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
