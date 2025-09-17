import 'package:test/test.dart';
import 'package:domain/policies/action_policies/action_policy.dart';

import '../../../utils/users.dart' show analyst, admin, user, otherUser;

void main() {
  group('UpdateUserEmailPolicy', () {
    final policy = UpdateUserEmailPolicy();

    test('analyst can update anyone', () {
      expect(policy.isPermitted(analyst, otherUser), isTrue);
      expect(policy.isPermitted(analyst, analyst), isTrue);
    });
    test('admin can update non-analyst, not analyst', () {
      expect(policy.isPermitted(admin, user), isTrue);
      expect(policy.isPermitted(admin, analyst), isFalse);
    });
    test('user can only update self', () {
      expect(policy.isPermitted(user, user), isTrue);
      expect(policy.isPermitted(user, otherUser), isFalse);
    });
  });
}
