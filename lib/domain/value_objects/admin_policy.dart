import 'package:dart_server/domain/value_objects/action.dart';
import 'package:dart_server/domain/value_objects/policy.dart';
import 'package:dart_server/domain/value_objects/resource.dart';
import 'package:dart_server/domain/value_objects/role.dart';

class AdminPolicy extends Policy {
  AdminPolicy({
    required Resource resource,
    required List<Action> actions,
  }) : super(
          role: Role.admin,
          resource: resource,
          actions: actions,
        );
}
