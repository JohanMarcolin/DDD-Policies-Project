import 'package:dart_server/domain/value_objects/action.dart';
import 'package:dart_server/domain/value_objects/resource.dart';
import 'package:dart_server/domain/value_objects/user_policy.dart';

final userPolicies = {
  UserPolicy(
    resource: Resource.self,
    actions: [Action.all],
  ),
  
};
