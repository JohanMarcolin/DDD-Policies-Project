import '../../../domain/entities/user.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/value_objects/email.dart';
import '../../../domain/value_objects/id.dart';
import '../../../domain/value_objects/password.dart';
import '../databases/user_database.dart';
import '../databases/user_password_database.dart';

class InMemoryUserRepository implements UserRepository {
  InMemoryUserRepository(
      UserDatabase userDb, UserPasswordDatabase userPasswordDb)
      : _userdb = userDb,
        _userPasswordDb = userPasswordDb;

  final UserDatabase _userdb;
  final UserPasswordDatabase _userPasswordDb;

  @override
  List<User> get users => _userdb.getAll();

  @override
  User? get({required Id id}) {
    return _userdb.get(id);
  }

  @override
  User? getByEmail({required Email email}) {
    final users = _userdb.getAll();

    return users.firstWhere((user) => user.email.value == email.value);
  }

  @override
  void updateEmail({required Id id, required Email newEmail}) {
    final user = _userdb.get(id);
    if (user != null) {
      final updated = User(
        id: user.id,
        email: newEmail,
        role: user.role,
      );
      _userdb.put(id, updated);
    }
  }

  @override
  void updatePassword({required Id id, required Password newPassword}) {
    final userPassword = _userPasswordDb.get(id);
    if (userPassword != null) {
      _userPasswordDb.put(id, newPassword);
    }
  }

  @override
  void delete({required Id id}) {
    _userdb.delete(id);
  }

  bool isPasswordVerified({required Id id, required Password password}) =>
      _userPasswordDb.isPasswordVerified(id, password);
}
