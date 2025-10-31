import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:flutter_test/flutter_test.dart';

class UserActionPolicyTestRunner {
  static Future<void> runAllTestCases({
    required ActionPolicy<User, User> actionPolicy,
    required List<User> users,
    required void Function(User currentUser, User targetUser)
    onActionAuthorized,
    required void Function(User currentUser, User targetUser, dynamic reason)
    onActionUnauthorized,
  }) async {
    for (final currentUser in users) {
      for (final targetUser in users) {
        group(
          currentUser.isSameAs(targetUser)
              ? '${currentUser.role.name} acting on self'
              : '${currentUser.role.name} acting on ${targetUser.role.name}',
          () {
            final result = actionPolicy.authorize(currentUser, targetUser);
            switch (result) {
              case Authorized():
                group('(action authorized)', () {
                  onActionAuthorized(currentUser, targetUser);
                });
              case Unauthorized(:final reason):
                group('(action unauthorized)', () {
                  onActionUnauthorized(currentUser, targetUser, reason);
                });
            }
          },
        );
      }
    }
  }
}
