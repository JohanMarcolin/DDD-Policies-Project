import 'user.dart';
import '../value_objects/role.dart';

class Admin extends User {
  Admin({
    required super.userId,
    required super.email,
  }) : super(role: Role.admin);
}
