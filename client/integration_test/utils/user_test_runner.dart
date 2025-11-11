import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:server/test/utils/factories/test_user_entry_factory.dart';

class UserTestRunner {
  static Future<void> userTestFixturePairs({
    required List<User> users,
    required void Function(User actor, User subject) onUserPairCase,
  }) async {
    _forEachUserPair(users: users, testCallback: onUserPairCase);
  }

  static Future<void> userTestFixturePolicy({
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

  static Future<void> testUserTestFixturePairs({
    required List<UserTestFixture> userTestFixtures,
    required void Function(UserTestFixture actor, UserTestFixture subject)
    onUserTestFixturePairCase,
  }) async {
    _forEachUserTestFixturePair(
      userTestFixtures: userTestFixtures,
      testCallback: onUserTestFixturePairCase,
    );
  }

  static Future<void> testUserTestFixturePolicy({
    required ActionPolicy<User, User> policy,
    required List<UserTestFixture> userTestFixtures,
    required void Function(UserTestFixture actor, UserTestFixture subject)
    onAuthorized,
    required void Function(UserTestFixture actor, UserTestFixture subject)
    onUnauthorized,
  }) async {
    _forEachUserTestFixturePair(
      userTestFixtures: userTestFixtures,
      testCallback: (actor, subject) {
        final result = policy.authorize(actor.user, subject.user);
        switch (result) {
          case Authorized():
            group('(action authorized)', () {
              onAuthorized(actor, subject);
            });
          case Unauthorized():
            group('(action unauthorized)', () {
              onUnauthorized(actor, subject);
            });
        }
      },
    );
  }

  static void _forEachUserTestFixturePair({
    required List<UserTestFixture> userTestFixtures,
    required void Function(UserTestFixture actor, UserTestFixture subject)
    testCallback,
  }) {
    for (final actor in userTestFixtures) {
      for (final subject in userTestFixtures) {
        group(
          actor.user.isSameAs(subject.user)
              ? '${actor.user.role.name} acting on self'
              : '${actor.user.role.name} acting on ${subject.user.role.name}',
          () {
            testCallback(actor, subject);
          },
        );
      }
    }
  }
}
