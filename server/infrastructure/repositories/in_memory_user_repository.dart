import '../../../domain/entities/user.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/value_objects/email.dart';
import '../../../domain/value_objects/id.dart';
import '../../../domain/value_objects/password.dart';
import '../databases/user_database.dart';
import '../databases/user_password_database.dart';

class InMemoryUserRepository implements UserRepository {
  InMemoryUserRepository(
      {required UserDatabase userDatabase,
      required UserPasswordDatabase userPasswordDatabase})
      : _userdatabase = userDatabase,
        _userPasswordDatabase = userPasswordDatabase;

  final UserDatabase _userdatabase;
  final UserPasswordDatabase _userPasswordDatabase;

  @override
  List<User> get users => _userdatabase.getAll();

  @override
  User? get({required Id id}) {
    return _userdatabase.get(id);
  }

  @override
  User? getByEmail({required Email email}) {
    final users = _userdatabase.getAll();

    return users.firstWhere((user) => user.email.value == email.value);
  }

  @override
  void updateEmail({required Id id, required Email newEmail}) {
    final user = _userdatabase.get(id);
    if (user != null) {
      final updated = User(
        id: user.id,
        email: newEmail,
        role: user.role,
      );
      _userdatabase.put(id, updated);
    }
  }

  @override
  void updatePassword({required Id id, required Password newPassword}) {
    final userPassword = _userPasswordDatabase.get(id);
    if (userPassword != null) {
      _userPasswordDatabase.put(id, newPassword);
    }
  }

  @override
  void delete({required Id id}) {
    _userdatabase.delete(id);
  }

  bool isPasswordVerified({required Id id, required Password password}) =>
      _userPasswordDatabase.isPasswordVerified(id, password);
}
