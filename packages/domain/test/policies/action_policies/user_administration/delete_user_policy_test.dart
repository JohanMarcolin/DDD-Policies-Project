import 'package:domain/policies/action_authorization_policies/user_administration/user_administration_policy.dart';
import 'package:test/test.dart';

import '../../../utils/users.dart' show analyst, admin, user, otherUser;

void main() {
  group('DeleteUserPolicy', () {
    final policy = DeleteUserPolicy();

    test('analyst can delete others but not self', () {
      expect(policy.isAuthorized(analyst, otherUser), isTrue);
      expect(policy.isAuthorized(analyst, analyst), isFalse);
      policy.apply(analyst, analyst,
          onAuthorized: () => fail('Analyst should not be able to delete self'),
          onUnauthorized: (reason) => expect(reason, isA<CannotDeleteSelf>()));
    });

    test('admin can delete non-analyst, not analyst', () {
      expect(policy.isAuthorized(admin, user), isTrue);
      expect(policy.isAuthorized(admin, analyst), isFalse);
      policy.apply(admin, analyst,
          onAuthorized: () => fail('Admin should not be able to delete analyst'),
          onUnauthorized: (reason) => expect(reason, isA<CannotDeleteAnalyst>()));
    });

    test('user can only delete self', () {
      expect(policy.isAuthorized(user, user), isTrue);
      expect(policy.isAuthorized(user, otherUser), isFalse);
      policy.apply(user, otherUser,
          onAuthorized: () => fail('User should not be able to delete other users'),
          onUnauthorized: (reason) => expect(reason, isA<CanOnlyDeleteSelf>()));
    });
  });
}
