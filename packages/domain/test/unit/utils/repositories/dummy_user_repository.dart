import 'package:domain/entities/user.dart';
import 'package:domain/repositories/user_repository.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/password.dart';

/// Dummy implementation of [UserRepository] for domain unit tests.
///
/// Stores users in memory and simulates repository operations.
class DummyUserRepository implements UserRepository {
  DummyUserRepository(List<User> users) : _users = users;

  final List<User> _users;

  /// Returns all users.
  @override
  Future<List<User>> get users async => _users;

  /// Returns the user with [userId], or null if not found.
  @override
  Future<User?> get({required UserId userId}) async => _users.where((u) => u.userId == userId).firstOrNull;

  /// Returns the user with [email], or null if not found.
  @override
  Future<User?> getByEmail({required Email email}) async => _users.where((u) => u.email == email).firstOrNull;

  /// Deletes the user with [userId].
  @override
  Future<void> delete({required UserId userId}) async {
    _users.removeWhere((u) => u.userId == userId);
  }

  /// Updates the email for the user with [userId].
  @override
  Future<void> updateEmail({required UserId userId, required Email newEmail}) async {
    final user = await get(userId: userId);
    if (user != null) {
      final updated = User(userId: user.userId, email: newEmail, role: user.role);
      final index = _users.indexWhere((u) => u.userId == userId);
      if (index != -1) _users[index] = updated;
    }
  }

  /// Updates the password for the user with [userId].
  @override
  Future<void> updatePassword({required UserId userId, required Password newPassword}) async {
    final user = await get(userId: userId);
    if (user != null) {
      final updated = User(userId: user.userId, email: user.email, role: user.role);
      final index = _users.indexWhere((u) => u.userId == userId);
      if (index != -1) _users[index] = updated;
    }
  }
}
