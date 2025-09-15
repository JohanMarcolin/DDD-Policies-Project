import 'user.dart';
import '../value_objects/email.dart';
import '../value_objects/id.dart';
import '../value_objects/role.dart';

class Admin extends User {
  Admin({
    required UserId userId,
    required Email email,
  }) : super(userId: userId, email: email, role: Role.admin);
}
