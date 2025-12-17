import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/password.dart';
import '../security/password_hasher.dart';
import 'in_memory_database.dart';

/// Provides an in-memory database for user [Password]:s associated with [UserId]s.
final class InMemoryUserPasswordDatabase extends InMemoryDatabase<UserId, Password> {
  InMemoryUserPasswordDatabase({required PasswordHasher passwordHasher}) : _passwordHasher = passwordHasher;

  final PasswordHasher _passwordHasher;

  /// Hashes the provided [value] and stores it for the given [key].
  ///
  /// Overwrites any existing password for [key].
  @override
  Future<void> put(UserId key, Password value) async => map[key] = _passwordHasher.hash(value);

  /// Verifies whether the provided [value] matches the stored hash for [key].
  ///
  /// Returns `false` if no password is stored for [key], or if the verification fails.
  Future<bool> isPasswordVerified(UserId key, Password value) async {
    final storedValue = map[key];
    if (storedValue == null) return false;
    return _passwordHasher.isVerified(value, storedValue);
  }
}
