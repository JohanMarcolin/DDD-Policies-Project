import 'package:client/infrastructure/apis/test_api.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:flutter_test/flutter_test.dart';

class UserTestRunner {
  static Future<void> testUserPairs({
    required List<User> users,
    required void Function(User actor, User subject) onUserPairCase,
  }) async {
    _forEachUserPair(users: users, testCallback: onUserPairCase);
  }

  static Future<void> testUserPolicy({
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

  static Future<void> userEntryPairs({
    required List<UserEntry> userEntries,
    required void Function(UserEntry actor, UserEntry subject)
    onUserEntryPairCase,
  }) async {
    _forEachUserEntryPair(
      userEntries: userEntries,
      testCallback: onUserEntryPairCase,
    );
  }

  static Future<void> testUserEntryPolicy({
    required ActionPolicy<User, User> policy,
    required List<UserEntry> userEntries,
    required void Function(UserEntry actor, UserEntry subject) onAuthorized,
    required void Function(UserEntry actor, UserEntry subject) onUnauthorized,
  }) async {
    _forEachUserEntryPair(
      userEntries: userEntries,
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

  static void _forEachUserEntryPair({
    required List<UserEntry> userEntries,
    required void Function(UserEntry actor, UserEntry subject) testCallback,
  }) {
    for (final actor in userEntries) {
      for (final subject in userEntries) {
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
