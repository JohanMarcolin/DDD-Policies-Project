import 'package:dart_server/domain/value_objects/action.dart';
import 'package:dart_server/domain/value_objects/resource.dart';
import 'package:dart_server/domain/value_objects/role.dart';

abstract class Policy {
  final Role role;
  final Resource resource;
  final List<Action> actions;

  Policy({
    required this.role,
    required this.resource,
    required this.actions,
  });
}
