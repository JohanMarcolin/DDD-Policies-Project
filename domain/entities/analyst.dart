import '../value_objects/email.dart';
import '../value_objects/id.dart';
import '../value_objects/role.dart';
import 'user.dart';

class Analyst extends User {
  Analyst({
    required UserId userId,
    required Email email,
  }) : super(userId: userId, email: email, role: Role.analyst);
}
