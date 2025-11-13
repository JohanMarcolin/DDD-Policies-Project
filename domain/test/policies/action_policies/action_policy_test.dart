import 'package:domain/policies/policy_violation_exception.dart';
import 'package:test/test.dart';

import '../../utils/policies/action_policies/dummy_action_policy.dart';

void main() {
  group('ActionPolicy', () {
    test('isAuthorized returns true for Granted', () {
      final policy = DummyAlwaysAuthorizedActionPolicy();
      expect(policy.isAuthorized('initiator', 'target'), isTrue);
    });

    test('isAuthorized returns false for Denied', () {
      final policy = DummyAlwaysUnauthorizedActionPolicy();
      expect(policy.isAuthorized('initiator', 'target'), isFalse);
    });

    test('enforce returns value for Granted', () {
      final policy = DummyAlwaysAuthorizedActionPolicy();
      final result = policy.requireAuthorization('initiator', 'target', onAuthorized: () => 'allowed');
      expect(result, equals('allowed'));
    });

    test('enforce throws ActionPolicyViolationException for Denied', () {
      final policy = DummyAlwaysUnauthorizedActionPolicy();
      expect(
        () => policy.requireAuthorization('initiator', 'target', onAuthorized: () => 'should not reach'),
        throwsA(isA<ActionPolicyViolationException>()),
      );
    });
  });
}
