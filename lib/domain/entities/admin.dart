import 'package:dart_server/domain/entities/user.dart';
import 'package:dart_server/domain/value_objects/email.dart';
import 'package:dart_server/domain/value_objects/id.dart';
import 'package:dart_server/domain/value_objects/role.dart';

class Admin extends User {
  Admin({
    required Id id,
    required Email email,
  }) : super(id: id, email: email, role: Role.admin);
}
