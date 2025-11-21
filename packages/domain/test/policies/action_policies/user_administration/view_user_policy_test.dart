import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:test/test.dart';

import '../../../utils/users.dart' show analyst, otherAnalyst, admin, otherAdmin, user, otherUser;

void main() {
  group('ViewUserPolicy', () {
    final policy = ViewUserPolicy();

    test('analyst can view anyone', () {
      expect(policy.isAuthorized(analyst, user), isTrue);
      expect(policy.isAuthorized(analyst, admin), isTrue);
      expect(policy.isAuthorized(analyst, analyst), isTrue);
      expect(policy.isAuthorized(analyst, otherAnalyst), isTrue);
    });
    test('admin can view non-analyst, not analyst', () {
      expect(policy.isAuthorized(admin, user), isTrue);
      expect(policy.isAuthorized(admin, admin), isTrue);
      expect(policy.isAuthorized(admin, otherAdmin), isTrue);
      expect(policy.isAuthorized(admin, analyst), isFalse);
    });
    test('user can view non-analyst, not analyst', () {
      expect(policy.isAuthorized(user, user), isTrue);
      expect(policy.isAuthorized(user, otherUser), isTrue);
      expect(policy.isAuthorized(user, admin), isTrue);
      expect(policy.isAuthorized(user, analyst), isFalse);
    });
  });
}
