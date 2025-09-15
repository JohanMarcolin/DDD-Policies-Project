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
  User? get({required UserId userId}) {
    return _userdatabase.get(userId);
  }

  @override
  User? getByEmail({required Email email}) {
    final users = _userdatabase.getAll();

    return users.firstWhere((user) => user.email.value == email.value);
  }

  @override
  void updateEmail({required UserId userId, required Email newEmail}) {
    final user = _userdatabase.get(userId);
    if (user != null) {
      final updated = User(
        userId: user.userId,
        email: newEmail,
        role: user.role,
      );
      _userdatabase.put(userId, updated);
    }
  }

  @override
  void updatePassword({required UserId userId, required Password newPassword}) {
    final userPassword = _userPasswordDatabase.get(userId);
    if (userPassword != null) {
      _userPasswordDatabase.put(userId, newPassword);
    }
  }

  @override
  void delete({required UserId userId}) {
    _userdatabase.delete(userId);
  }

  bool isPasswordVerified({required UserId userId, required Password password}) =>
      _userPasswordDatabase.isPasswordVerified(userId, password);
}
