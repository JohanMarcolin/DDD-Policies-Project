import 'package:equatable/equatable.dart';

import '../value_objects/action.dart';
import '../value_objects/email.dart';
import '../value_objects/id.dart';
import '../value_objects/password.dart';
import '../value_objects/permission.dart';
import '../value_objects/resource.dart';
import '../value_objects/role.dart';

class User extends Equatable {
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

  @override
  List<Object?> get props => [id];

  static final List<Permission> permissions = [
    Permission([Action.read], [Resource.self, Resource.user, Resource.admin]),
    Permission([Action.write, Action.delete], [Resource.self]),
  ];
}
