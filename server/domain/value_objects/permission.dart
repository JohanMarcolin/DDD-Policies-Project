import 'action.dart';
import 'resource.dart';

class Permission {
  final List<Action> actions;
  final List<Resource> resources;

  Permission(this.actions, this.resources);
}
