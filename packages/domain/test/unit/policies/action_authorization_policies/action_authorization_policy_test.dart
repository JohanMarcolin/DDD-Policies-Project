import 'package:domain/policies/action_authorization_policies/action_authorization_policy.dart';
import 'package:domain/policies/policy_violation_exception.dart';
import 'package:test/test.dart';

void main() {
  final alwaysAuthorizedPolicy = _DummyAlwaysAuthorizedActionAuthorizationPolicy();
  final alwaysUnauthorizedPolicy = _DummyAlwaysUnauthorizedActionAuthorizationPolicy();

  group('ActionAuthorizationPolicy', () {
    test('isAuthorized returns true for alwaysAuthorizedPolicy', () {
      expect(alwaysAuthorizedPolicy.isAuthorized('initiator', 'target'), isTrue, reason: 'Should be authorized');
    });

    test('isAuthorized returns false for alwaysUnauthorizedPolicy', () {
      expect(alwaysUnauthorizedPolicy.isAuthorized('initiator', 'target'), isFalse, reason: 'Should be unauthorized');
    });

    test('apply calls onAuthorized for alwaysAuthorizedPolicy', () {
      var called = false;
      alwaysAuthorizedPolicy.apply(
        actor: 'initiator',
        resource: 'target',
        onAuthorized: () => called = true,
        onUnauthorized: (_) => fail('Should not call onUnauthorized'),
      );
      expect(called, isTrue, reason: 'Should call onAuthorized when authorized');
    });

    test('apply calls onUnauthorized for alwaysUnauthorizedPolicy', () {
      var called = false;
      alwaysUnauthorizedPolicy.apply(
        actor: 'initiator',
        resource: 'target',
        onAuthorized: () => fail('Should not call onAuthorized'),
        onUnauthorized: (reason) {
          called = true;
          expect(reason, isA<_DummyUnauthorizedReason>(), reason: 'Reason should be provided when unauthorized');
        },
      );
      expect(called, isTrue, reason: 'Should call onUnauthorized when unauthorized');
    });

    test('enforce returns value for alwaysAuthorizedPolicy', () {
      final result = alwaysAuthorizedPolicy.enforce('initiator', 'target', onAuthorized: () => 'allowed');
      expect(result, equals('allowed'), reason: 'Should return value when authorized');
    });

    test('enforce throws exception for alwaysUnauthorizedPolicy', () {
      expect(
        () => alwaysUnauthorizedPolicy.enforce('initiator', 'target', onAuthorized: () => 'should not reach'),
        throwsA(predicate((e) => e is PolicyViolationException && e.reason is _DummyUnauthorizedReason)),
        reason: 'Should throw exception with reason when unauthorized',
      );
    });

    test('enforce returns normally for alwaysAuthorizedPolicy', () {
      expect(() => alwaysAuthorizedPolicy.enforce('initiator', 'target', onAuthorized: () {}), returnsNormally,
          reason: 'Should not throw');
    });
  });
}

/// A dummy authorization policy that always returns authorized.
final class _DummyAlwaysAuthorizedActionAuthorizationPolicy
    extends ActionAuthorizationPolicy<String, String, _DummyUnauthorizedReason> {
  _DummyAlwaysAuthorizedActionAuthorizationPolicy()
      : super(authorize: (String initiator, String target) => Authorized());
}

/// A dummy authorization policy that always returns unauthorized.
final class _DummyAlwaysUnauthorizedActionAuthorizationPolicy
    extends ActionAuthorizationPolicy<String, String, _DummyUnauthorizedReason> {
  _DummyAlwaysUnauthorizedActionAuthorizationPolicy()
      : super(authorize: (String initiator, String target) => Unauthorized(reason: _DummyUnauthorizedReason()));
}

final class _DummyUnauthorizedReason extends ActionUnauthorizedReason {}
