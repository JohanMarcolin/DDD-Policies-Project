import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:test/test.dart';

/// Utility class to run tests for different user role combinations.
class UserTestRunner {
  /// Iterates over all pairs of [users] and invokes [onUserPairCase] for each actor/subject combination.
  ///
  /// Useful for generating tests that need to cover all possible user-to-user scenarios.
  static Future<void> forEachUserPair({
    required List<User> users,
    required void Function(User actor, User subject) onUserPairCase,
  }) async {
    _iterateUserPairs(users: users, testCallback: onUserPairCase);
  }

  /// Iterates over all pairs of [users], applies [policy], and invokes [onAuthorized] or [onUnauthorized]
  /// depending on the policy result for each actor/subject combination.
  ///
  /// This method is useful for policy-driven tests, ensuring both authorized and unauthorized cases are covered.
  static Future<void> forEachUserPairWithPolicy({
    required ActionPolicy<User, User> policy,
    required List<User> users,
    required void Function(User actor, User subject) onAuthorized,
    required void Function(User actor, User subject, dynamic reason) onUnauthorized,
  }) async {
    _iterateUserPairs(
      users: users,
      testCallback: (actor, subject) {
        final result = policy.authorize(actor, subject);
        if (result is Authorized) {
          group('(action authorized)', () {
            onAuthorized(actor, subject);
          });
        } else if (result is Unauthorized) {
          group('(action unauthorized)', () {
            onUnauthorized(actor, subject, result.reason);
          });
        }
      },
    );
  }

  /// Internal helper to iterate over all actor/subject pairs in [users] and invoke [testCallback].
  static void _iterateUserPairs({
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
