import 'package:domain/policies/policy_violation_exception.dart';
import 'package:test/test.dart';

import '../../utils/policies/action_policies/dummy_action_policy.dart';

void main() {
  group('ActionAuthorizationPolicy', () {
    test('isAuthorized returns true for Granted', () {
      final policy = DummyAlwaysAuthorizedActionAuthorizationPolicy();
      expect(policy.isAuthorized('initiator', 'target'), isTrue);
    });

    test('isAuthorized returns false for Denied', () {
      final policy = DummyAlwaysUnauthorizedActionAuthorizationPolicy();
      expect(policy.isAuthorized('initiator', 'target'), isFalse);
    });

    test('enforce returns value when authorized', () {
      final policy = DummyAlwaysAuthorizedActionAuthorizationPolicy();
      final result = policy.enforce('initiator', 'target', onAuthorized: () => 'allowed');
      expect(result, equals('allowed'));
    });

    test('enforce throws ActionAuthorizationPolicyViolationException when unauthorized', () {
      final policy = DummyAlwaysUnauthorizedActionAuthorizationPolicy();
      expect(
        () => policy.enforce('initiator', 'target', onAuthorized: () => 'should not reach'),
        throwsA(isA<ActionAuthorizationPolicyViolationException>()),
      );
    });
  });
}
