import 'package:equatable/equatable.dart';

import '../../value_objects/email.dart';
import '../../value_objects/id.dart';
import '../../value_objects/role.dart';

class User extends Equatable {
  User({
    required this.userId,
    required this.email,
    this.role = Role.user,
  });

  final UserId userId;
  final Email email;
  final Role role;

  @override
  List<Object?> get props => [userId];

  bool isSameAs(User other) => userId == other.userId;

  bool get isAdmin => role == Role.admin;

  bool get isAnalyst => role == Role.analyst;
}
