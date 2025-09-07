import 'user.dart';
import '../value_objects/email.dart';
import '../value_objects/id.dart';
import '../value_objects/role.dart';

class Admin extends User {
  Admin({
    required Id id,
    required Email email,
  }) : super(id: id, email: email, role: Role.admin);
}
