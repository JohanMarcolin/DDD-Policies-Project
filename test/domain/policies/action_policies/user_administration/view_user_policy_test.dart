import 'package:test/test.dart';

import '../../../../../domain/policies/action_policies/action_policy.dart';
import '../../../../utils/factories/test_user_factory.dart';

void main() {
  group('ViewUserPolicy', () {
    final analyst = TestUserFactory.analyst1;
    final admin = TestUserFactory.admin1;
    final user = TestUserFactory.user1;
    final otherUser = TestUserFactory.user2;

    final policy = ViewUserPolicy();

    test('analyst can view anyone', () {
      expect(policy.isPermitted(analyst, otherUser), isTrue);
      expect(policy.isPermitted(analyst, analyst), isTrue);
    });
    test('admin can view non-analyst, not analyst', () {
      expect(policy.isPermitted(admin, user), isTrue);
      expect(policy.isPermitted(admin, analyst), isFalse);
    });
    test('user can only view self', () {
      expect(policy.isPermitted(user, user), isTrue);
      expect(policy.isPermitted(user, otherUser), isFalse);
    });
  });
}
