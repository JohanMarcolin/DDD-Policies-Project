import 'package:dart_server/domain/value_objects/action.dart';
import 'package:dart_server/domain/value_objects/resource.dart';

class Permission {
  final List<Action> actions;
  final List<Resource> resources;

  Permission(this.actions, this.resources);
}
