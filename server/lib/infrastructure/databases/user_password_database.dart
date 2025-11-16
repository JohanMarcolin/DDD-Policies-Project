import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/password.dart';
import '../security/password_hasher.dart';
import 'database.dart';

class UserPasswordDatabase implements Database<Password> {
  UserPasswordDatabase({required PasswordHasher passwordHasher}) : _passwordHasher = passwordHasher;

  final PasswordHasher _passwordHasher;

  final Map<Id, Password> _passwords = {};

  @override
  Future<Password?> get(Id id) async => _passwords[id];

  @override
  Future<List<Password>> getAll() async => _passwords.values.toList();

  @override
  Future<void> put(Id id, Password password) async => _passwords[id] = _passwordHasher.hash(password);

  @override
  Future<void> delete(Id id) async => _passwords.remove(id);

  Future<bool> isPasswordVerified(Id id, Password password) async {
    final storedPassword = _passwords[id];
    if (storedPassword == null) {
      return false;
    }
    return _passwordHasher.isVerified(password, storedPassword);
  }
}
