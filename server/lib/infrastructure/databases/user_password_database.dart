import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/password.dart';
import '../security/password_hasher.dart';
import 'database.dart';

class UserPasswordDatabase implements Database<Password> {
  UserPasswordDatabase({required PasswordHasher passwordHasher}) : _passwordHasher = passwordHasher;

  final PasswordHasher _passwordHasher;

  final Map<Id, Password> _passwords = {};

  @override
  Password? get(Id id) => _passwords[id];

  @override
  List<Password> getAll() => _passwords.values.toList();

  @override
  void put(Id id, Password password) {
    _passwords[id] = _passwordHasher.hash(password);
  }

  @override
  void delete(Id id) {
    _passwords.remove(id);
  }

  bool isPasswordVerified(Id id, Password password) {
    final storedPassword = _passwords[id];
    if (storedPassword == null) {
      return false;
    }
    return _passwordHasher.isVerified(password, storedPassword);
  }
}
