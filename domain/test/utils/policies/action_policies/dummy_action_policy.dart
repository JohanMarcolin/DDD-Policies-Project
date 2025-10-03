import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:domain/policies/policy_violation_exception.dart';

final class DummyAlwaysGrantedActionPolicy
    extends ActionPolicy<String, String, DummyActionPolicyResult> {
  const DummyAlwaysGrantedActionPolicy();

  @override
  bool isAuthorized(String initiator, String target) => true;

  @override
  DummyActionPolicyResult authorize(String initiator, String target) =>
      DummyGranted();

  @override
  requireAuthorization(String initiator, String target,
          {required Function() onAuthorized}) =>
      onAuthorized();
}

final class DummyAlwaysDeniedActionPolicy
    extends ActionPolicy<String, String, DummyActionPolicyResult> {
  const DummyAlwaysDeniedActionPolicy();

  @override
  bool isAuthorized(String initiator, String target) => false;

  @override
  DummyActionPolicyResult authorize(String initiator, String target) =>
      DummyDenied(reason: DummyIsAlwaysDenied());

  @override
  requireAuthorization(String initiator, String target,
      {required Function() onAuthorized}) {
    if (isAuthorized(initiator, target)) {
      return onAuthorized();
    } else {
      throw ActionPolicyViolationException(DummyIsAlwaysDenied());
    }
  }
}

sealed class DummyActionPolicyResult {}

class DummyGranted extends DummyActionPolicyResult {}

class DummyDenied extends DummyActionPolicyResult {
  DummyDenied({required this.reason});

  final DummyDeniedReason reason;
}

sealed class DummyDeniedReason {}

class DummyIsAlwaysDenied implements DummyDeniedReason {}
