import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:test/test.dart';

import '../../../utils/users.dart' show analyst, admin, user, otherUser;

void main() {
  group('DeleteUserPolicy', () {
    final policy = DeleteUserPolicy();

    test('analyst can delete others but not self', () {
      expect(policy.isAuthorized(analyst, otherUser), isTrue);
      expect(policy.isAuthorized(analyst, analyst), isFalse);
      final denied = policy.authorize(analyst, analyst);
      expect(denied, isA<DeleteUserDenied>());
      expect((denied as DeleteUserDenied).reason, isA<CanOnlyDeleteSelf>());
    });

    test('admin can delete non-analyst, not analyst', () {
      expect(policy.isAuthorized(admin, user), isTrue);
      expect(policy.isAuthorized(admin, analyst), isFalse);
      final denied = policy.authorize(admin, analyst);
      expect(denied, isA<DeleteUserDenied>());
      expect((denied as DeleteUserDenied).reason, isA<CannotDeleteAnalyst>());
    });

    test('user can only delete self', () {
      expect(policy.isAuthorized(user, user), isTrue);
      expect(policy.isAuthorized(user, otherUser), isFalse);
      final denied = policy.authorize(user, otherUser);
      expect(denied, isA<DeleteUserDenied>());
      expect((denied as DeleteUserDenied).reason, isA<CanOnlyDeleteSelf>());
    });
  });
}
