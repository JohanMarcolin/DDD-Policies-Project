import 'package:test/test.dart';

import '../../../../../domain/policies/action_policies/action_policy.dart';
import '../../../../../domain/policies/action_policies/action_policy_permission.dart';
import '../../../../test_data_factories/test_user_factory.dart';



void main() {
  group('DeleteUserPolicy', () {

    final analyst = TestUserFactory.analyst1;
    final admin = TestUserFactory.admin1;
    final user = TestUserFactory.user1;
    final otherUser = TestUserFactory.user2;

    final policy = DeleteUserPolicy();

    test('analyst can delete others but not self', () {
      expect(policy.isPermitted(analyst, otherUser), isTrue);
      expect(policy.isPermitted(analyst, analyst), isFalse);
      final denied = policy.evaluatePermission(analyst, analyst);
      expect(denied, isA<Denied>());
      expect((denied as Denied).reason, isA<CanOnlyDeleteSelf>());
    });

    test('admin can delete non-analyst, not analyst', () {
      expect(policy.isPermitted(admin, user), isTrue);
      expect(policy.isPermitted(admin, analyst), isFalse);
      final denied = policy.evaluatePermission(admin, analyst);
      expect(denied, isA<Denied>());
      expect((denied as Denied).reason, isA<CannotDeleteAnalyst>());
    });

    test('user can only delete self', () {
      expect(policy.isPermitted(user, user), isTrue);
      expect(policy.isPermitted(user, otherUser), isFalse);
      final denied = policy.evaluatePermission(user, otherUser);
      expect(denied, isA<Denied>());
      expect((denied as Denied).reason, isA<CanOnlyDeleteSelf>());
    });
  });
}
