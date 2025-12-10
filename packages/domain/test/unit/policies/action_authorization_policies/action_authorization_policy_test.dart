import 'package:domain/policies/policy_violation_exception.dart';
import 'package:test/test.dart';

import '../../utils/policies/action_authorization_policies/dummy_action_authorization_policy.dart';

void main() {
  group('ActionAuthorizationPolicy', () {
    test('isAuthorized returns true for Granted', () {
      final policy = DummyAlwaysAuthorizedActionAuthorizationPolicy();
      expect(policy.isAuthorized('initiator', 'target'), isTrue,
          reason: 'Should be authorized for DummyAlwaysAuthorizedActionAuthorizationPolicy');
    });

    test('isAuthorized returns false for Denied', () {
      final policy = DummyAlwaysUnauthorizedActionAuthorizationPolicy();
      expect(policy.isAuthorized('initiator', 'target'), isFalse,
          reason: 'Should not be authorized for DummyAlwaysUnauthorizedActionAuthorizationPolicy');
    });

    test('apply calls onAuthorized when authorized', () {
      final policy = DummyAlwaysAuthorizedActionAuthorizationPolicy();
      var called = false;
      policy.apply(
        actor: 'initiator',
        resource: 'target',
        onAuthorized: () => called = true,
        onUnauthorized: (_) => fail('Should not call onUnauthorized'),
      );
      expect(called, isTrue, reason: 'Should call onAuthorized when authorized');
    });

    test('apply calls onUnauthorized when unauthorized', () {
      final policy = DummyAlwaysUnauthorizedActionAuthorizationPolicy();
      var called = false;
      policy.apply(
        actor: 'initiator',
        resource: 'target',
        onAuthorized: () => fail('Should not call onAuthorized'),
        onUnauthorized: (reason) {
          called = true;
          expect(reason, isNotNull, reason: 'Reason should be provided when unauthorized');
        },
      );
      expect(called, isTrue, reason: 'Should call onUnauthorized when unauthorized');
    });

    test('enforce returns value when authorized', () {
      final policy = DummyAlwaysAuthorizedActionAuthorizationPolicy();
      final result = policy.enforce('initiator', 'target', onAuthorized: () => 'allowed');
      expect(result, equals('allowed'), reason: 'Should return value when authorized');
    });

    test('enforce throws ActionAuthorizationPolicyViolationException when unauthorized', () {
      final policy = DummyAlwaysUnauthorizedActionAuthorizationPolicy();
      expect(
        () => policy.enforce('initiator', 'target', onAuthorized: () => 'should not reach'),
        throwsA(isA<PolicyViolationException>()),
        reason: 'Should throw PolicyViolationException when unauthorized',
      );
    });
  });
}
