import 'package:domain/policies/policy_exception.dart';
import 'package:test/test.dart';

import '../../utils/policies/action_policies/dummy_action_policy.dart';

void main() {
  group('ActionPolicy', () {
    test('isPermitted returns true for Granted', () {
      final policy = DummyAlwaysGrantedActionPolicy();
      expect(policy.isPermitted('initiator', 'target'), isTrue);
    });

    test('isPermitted returns false for Denied', () {
      final policy = DummyAlwaysDeniedActionPolicy();
      expect(policy.isPermitted('initiator', 'target'), isFalse);
    });

    test('enforce returns value for Granted', () {
      final policy = DummyAlwaysGrantedActionPolicy();
      final result =
          policy.enforce('initiator', 'target', onGranted: () => 'allowed');
      expect(result, equals('allowed'));
    });

    test('enforce throws ActionPolicyViolationException for Denied', () {
      final policy = DummyAlwaysDeniedActionPolicy();
      expect(
        () => policy.enforce('initiator', 'target',
            onGranted: () => 'should not reach'),
        throwsA(isA<ActionPolicyViolationException>()),
      );
    });
  });
}
