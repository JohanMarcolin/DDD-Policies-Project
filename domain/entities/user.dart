import 'package:equatable/equatable.dart';

import '../value_objects/email.dart';
import '../value_objects/id.dart';
import '../value_objects/role.dart';

class User extends Equatable {
  User({
    required this.id,
    required this.email,
    this.role = Role.user,
  });

  final Id id;
  final Email email;
  final Role role;

  @override
  List<Object?> get props => [id];

  bool isSameAs(User other) => id == other.id;

  bool isAdmin() => role == Role.admin;

  bool isAnalyst() => role == Role.analyst;
}
