part of '../user_administration_view.dart';

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
