import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:test/test.dart';

import '../../../utils/users.dart' show analyst, admin, user, otherUser;

void main() {
  group('ViewUserPolicy', () {
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
