import 'package:domain/entities/user.dart';

/// Utility for iterating and testing all user pairs in general or authorization scenarios.
///
/// Provides methods to systematically perform operations or tests for all combinations of initiator and target users.
class UserPairTestUtil {
  /// Iterates over all pairs of [users] and invokes [onUserPair] for each initiator/target combination.
  ///
  /// Use this to perform operations or tests all user pairs.
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
