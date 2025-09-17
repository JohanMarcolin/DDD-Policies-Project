import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:domain/policies/action_policies/action_policy_permission.dart';

class DummyAlwaysGrantedActionPolicy extends ActionPolicy<dynamic, dynamic> {
  @override
  ActionPolicyPermission evaluatePermission(
          dynamic initiator, dynamic target) =>
      Granted();
}

class DummyAlwaysDeniedActionPolicy extends ActionPolicy<dynamic, dynamic> {
  @override
  ActionPolicyPermission evaluatePermission(
          dynamic initiator, dynamic target) =>
      Denied(reason: 'denied');
}
