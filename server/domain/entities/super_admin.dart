import '../value_objects/password.dart';
import 'user.dart';
import '../value_objects/action.dart';
import '../value_objects/email.dart';
import '../value_objects/id.dart';
import '../value_objects/permission.dart';
import '../value_objects/resource.dart';
import '../value_objects/role.dart';

class SuperAdmin extends User {
  SuperAdmin({
    required Id id,
    required Email email,
    required Password password,
  }) : super(id: id, email: email, password: password, role: Role.superAdmin);

  static final List<Permission> permissions = [
    Permission(Action.values, Resource.values),
  ];
}
