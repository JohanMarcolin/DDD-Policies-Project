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
    this.role = Role.user,
  });

  final Id id;
  final Email email;
  final Password password;
  final Role role;

  @override
  List<Object?> get props => [id];

  bool isSameAs(User other) => id == other.id;

  bool isAnalyst() => role == Role.analyst;

  static final List<Permission> permissions = [
    Permission([Action.read], [Resource.self, Resource.user, Resource.admin]),
    Permission([Action.write, Action.delete], [Resource.self]),
  ];
}
