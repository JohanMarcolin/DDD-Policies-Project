import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:test/test.dart';

import '../../../utils/users.dart' show analyst, admin, user, otherUser;

void main() {
  group('DeleteUserPolicy', () {
    final policy = DeleteUserPolicy();

    test('analyst can delete others but not self', () {
      expect(policy.isAuthorized(analyst, otherUser), isTrue);
      expect(policy.isAuthorized(analyst, analyst), isFalse);
      final result = policy.authorize(analyst, analyst);
      expect(result, isA<Unauthorized>());
      expect((result as Unauthorized).reason, isA<CannotDeleteSelf>());
    });

    test('admin can delete non-analyst, not analyst', () {
      expect(policy.isAuthorized(admin, user), isTrue);
      expect(policy.isAuthorized(admin, analyst), isFalse);
      final result = policy.authorize(admin, analyst);
      expect(result, isA<Unauthorized>());
      expect((result as Unauthorized).reason, isA<CannotDeleteAnalyst>());
    });

    test('user can only delete self', () {
      expect(policy.isAuthorized(user, user), isTrue);
      expect(policy.isAuthorized(user, otherUser), isFalse);
      final result = policy.authorize(user, otherUser);
      expect(result, isA<Unauthorized>());
      expect((result as Unauthorized).reason, isA<CanOnlyDeleteSelf>());
    });
  });
}
