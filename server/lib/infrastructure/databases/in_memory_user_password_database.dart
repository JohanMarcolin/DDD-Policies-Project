import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/password.dart';
import '../security/password_hasher.dart';
import 'in_memory_database.dart';

/// Provides an in-memory database for user passwords associated with [UserId]s.
class InMemoryUserPasswordDatabase implements InMemoryDatabase<UserId, Password> {
  InMemoryUserPasswordDatabase({required PasswordHasher passwordHasher}) : _passwordHasher = passwordHasher;

  final PasswordHasher _passwordHasher;

  final Map<UserId, Password> _passwords = {};

  @override
  Future<Password?> get(UserId id) async => _passwords[id];

  @override
  Future<List<Password>> getAll() async => _passwords.values.toList();

  @override
  Future<void> put(UserId id, Password password) async => _passwords[id] = _passwordHasher.hash(password);

  @override
  Future<void> delete(UserId id) async => _passwords.remove(id);

  Future<bool> isPasswordVerified(UserId id, Password password) async {
    final storedPassword = _passwords[id];
    if (storedPassword == null) {
      return false;
    }
    return _passwordHasher.isVerified(password, storedPassword);
  }
}
