import 'package:test/test.dart';

import '../../../../domain/policies/action_policies/action_policy.dart';
import '../../../../domain/policies/action_policies/action_policy_permission.dart';
import '../../../../domain/policies/policy_exception.dart';

class DummyGrantedPolicy extends ActionPolicy<String, String> {
  @override
  ActionPolicyPermission evaluatePermission(String initiator, String target) =>
      Granted();
}

class DummyDeniedPolicy extends ActionPolicy<String, String> {
  @override
  ActionPolicyPermission evaluatePermission(String initiator, String target) =>
      Denied(reason: 'denied');
}

void main() {
  group('ActionPolicy', () {
    test('isPermitted returns true for Granted', () {
      final policy = DummyGrantedPolicy();
      expect(policy.isPermitted('initiator', 'target'), isTrue);
    });

    test('isPermitted returns false for Denied', () {
      final policy = DummyDeniedPolicy();
      expect(policy.isPermitted('initiator', 'target'), isFalse);
    });

    test('enforce returns value for Granted', () {
      final policy = DummyGrantedPolicy();
      final result =
          policy.enforce('initiator', 'target', onGranted: () => 'allowed');
      expect(result, equals('allowed'));
    });

    test('enforce throws ActionPolicyException for Denied', () {
      final policy = DummyDeniedPolicy();
      expect(
        () => policy.enforce('initiator', 'target',
            onGranted: () => 'should not reach'),
        throwsA(isA<ActionPolicyException>()),
      );
    });
  });
}
