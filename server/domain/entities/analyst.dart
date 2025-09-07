import '../value_objects/email.dart';
import '../value_objects/id.dart';
import '../value_objects/role.dart';
import 'user.dart';

class Analyst extends User {
  Analyst({
    required Id id,
    required Email email,
  }) : super(id: id, email: email, role: Role.analyst);
}
