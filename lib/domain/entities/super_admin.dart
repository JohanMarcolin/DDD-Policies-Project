import 'package:dart_server/domain/entities/user.dart';
import 'package:dart_server/domain/value_objects/action.dart';
import 'package:dart_server/domain/value_objects/email.dart';
import 'package:dart_server/domain/value_objects/id.dart';
import 'package:dart_server/domain/value_objects/permission.dart';
import 'package:dart_server/domain/value_objects/resource.dart';
import 'package:dart_server/domain/value_objects/role.dart';

class SuperAdmin extends User {
  SuperAdmin({
    required Id id,
    required Email email,
  }) : super(id: id, email: email, role: Role.superAdmin);

  static final List<Permission> permissions = [
    Permission(Action.values, Resource.values),
  ];
}
