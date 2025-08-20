import 'package:dart_server/domain/value_objects/email.dart';
import 'package:dart_server/domain/value_objects/id.dart';
import 'package:dart_server/domain/value_objects/role.dart';

class User {
  User({
    required this.id,
    required this.email,
    required this.role,
  });

  final Id id;
  final Email email;
  final Role role;
}
