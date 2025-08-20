import 'package:dart_server/domain/value_objects/action.dart';
import 'package:dart_server/domain/value_objects/policy.dart';
import 'package:dart_server/domain/value_objects/resource.dart';
import 'package:dart_server/domain/value_objects/role.dart';

class SuperAdminPolicy extends Policy {
  SuperAdminPolicy({
    required Resource resource,
    required List<Action> actions,
  }) : super(
          role: Role.superAdmin,
          resource: resource,
          actions: actions,
        );
}
