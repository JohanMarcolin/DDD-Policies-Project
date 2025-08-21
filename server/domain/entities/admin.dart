import '../value_objects/password.dart';
import 'user.dart';
import '../value_objects/action.dart';
import '../value_objects/email.dart';
import '../value_objects/id.dart';
import '../value_objects/permission.dart';
import '../value_objects/resource.dart';
import '../value_objects/role.dart';

class Admin extends User {
  Admin({
    required Id id,
    required Email email,
    required Password password,
  }) : super(id: id, email: email, password: password, role: Role.admin);

    static final List<Permission> permissions = [
    Permission([Action.read], Resource.values),
    Permission([Action.write], [Resource.self, Resource.user]),
    Permission([Action.delete], [Resource.user]),
  ];
}
