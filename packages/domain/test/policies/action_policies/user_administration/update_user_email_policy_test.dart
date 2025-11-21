import 'package:test/test.dart';
import 'package:domain/policies/action_policies/action_policy.dart';

import '../../../utils/users.dart' show analyst, admin, user, otherUser;

void main() {
  group('UpdateUserEmailPolicy', () {
    final policy = UpdateUserEmailPolicy();

    test('analyst can update anyone', () {
      expect(policy.isAuthorized(analyst, otherUser), isTrue);
      expect(policy.isAuthorized(analyst, analyst), isTrue);
    });
    test('admin can update non-analyst, not analyst', () {
      expect(policy.isAuthorized(admin, user), isTrue);
      expect(policy.isAuthorized(admin, analyst), isFalse);
    });
    test('user can only update self', () {
      expect(policy.isAuthorized(user, user), isTrue);
      expect(policy.isAuthorized(user, otherUser), isFalse);
    });
  });
}
