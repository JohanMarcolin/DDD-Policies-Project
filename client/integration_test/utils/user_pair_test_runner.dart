import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:flutter_test/flutter_test.dart';

class UserPairTestRunner {
  static Future<void> testAllUserPairCases({
    required List<User> users,
    required void Function(User actor, User subject) onUserPairCase,
  }) async {
    _forEachUserPair(users: users, testCallback: onUserPairCase);
  }

  static Future<void> testAllUserPolicyCases({
    required ActionPolicy<User, User> policy,
    required List<User> users,
    required void Function(User actor, User subject) onAuthorized,
    required void Function(User actor, User subject, dynamic reason)
    onUnauthorized,
  }) async {
    _forEachUserPair(
      users: users,
      testCallback: (actor, subject) {
        final result = policy.authorize(actor, subject);
        switch (result) {
          case Authorized():
            group('(action authorized)', () {
              onAuthorized(actor, subject);
            });
          case Unauthorized(:final reason):
            group('(action unauthorized)', () {
              onUnauthorized(actor, subject, reason);
            });
        }
      },
    );
  }

  static void _forEachUserPair({
    required List<User> users,
    required void Function(User actor, User subject) testCallback,
  }) {
    for (final actor in users) {
      for (final subject in users) {
        group(
          actor.isSameAs(subject)
              ? '${actor.role.name} acting on self'
              : '${actor.role.name} acting on ${subject.role.name}',
          () {
            testCallback(actor, subject);
          },
        );
      }
    }
  }
}
