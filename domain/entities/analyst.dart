import '../value_objects/role.dart';
import 'user.dart';

class Analyst extends User {
  Analyst({
    required super.userId,
    required super.email,
  }) : super(role: Role.analyst);
}
