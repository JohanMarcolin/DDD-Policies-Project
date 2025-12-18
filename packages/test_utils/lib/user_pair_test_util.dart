import 'package:domain/entities/user.dart';

/// Utility for iterating all user pairs.
///
/// Provides methods to perform tests for all combinations of initiator and target users.
class UserPairTestUtil {
  /// Iterates over all pairs of [users] and invokes [onUserPair] for each initiator/target combination.
  ///
  /// Use this to perform tests on all provided user pairs.
  ///
  /// [users] - List of users to test as initiator and target.
  /// [onUserPair] - Callback invoked for each user pair.
  static void forEachUserPair({
    required List<User> users,
    required void Function(User initiator, User target) onUserPair,
  }) {
    for (final initiator in users) {
      for (final target in users) {
        onUserPair(initiator, target);
      }
    }
  }
}
