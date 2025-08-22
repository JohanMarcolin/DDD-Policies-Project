import '../value_objects/action.dart';
import '../value_objects/email.dart';
import '../value_objects/id.dart';
import '../value_objects/password.dart';
import '../value_objects/permission.dart';
import '../value_objects/resource.dart';
import '../value_objects/role.dart';
import 'admin.dart';
import 'super_admin.dart';

class User {
  User({
    required this.id,
    required this.email,
    required this.password,
    required this.role,
  });

  final Id id;
  final Email email;
  final Password password;
  final Role role;

  static final List<Permission> permissions = [
    Permission([Action.read], [Resource.self, Resource.user, Resource.admin]),
    Permission([Action.write, Action.delete], [Resource.self]),
  ];
}
