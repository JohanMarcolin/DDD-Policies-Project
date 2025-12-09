import '../entities/user.dart';
import '../../value_objects/email.dart';
import '../../value_objects/id.dart';
import '../../value_objects/password.dart';

/// Repository interface for user operations.
///
/// Provides methods for retrieving and modifying users.
abstract class UserRepository {
  /// Returns all users.
  Future<List<User>> get users;

  /// Returns the user with the given [userId], or null if not found.
  Future<User?> get({required UserId userId});

  /// Returns the user with the given [email], or null if not found.
  Future<User?> getByEmail({required Email email});

  /// Deletes the user with the given [userId].
  Future<void> delete({required UserId userId});

  /// Updates the email with [newEmail] for the user with the given [userId].
  Future<void> updateEmail({required UserId userId, required Email newEmail});

  /// Updates the password with [newPassword] for the user with the given [userId].
  Future<void> updatePassword({required UserId userId, required Password newPassword});
}
