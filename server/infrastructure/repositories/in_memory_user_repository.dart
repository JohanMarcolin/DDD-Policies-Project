import 'package:domain/entities/user.dart';
import 'package:domain/repositories/user_repository.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/password.dart';
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
  Future<List<User>> get users async {
    return _userdatabase.getAll();
  }

  @override
  Future<User?> get({required UserId userId}) async {
    return _userdatabase.get(userId);
  }

  @override
  Future<User?> getByEmail({required Email email}) async {
    final users = _userdatabase.getAll();

    return users.firstWhere((user) => user.email.value == email.value);
  }

  @override
  Future<void> updateEmail({required UserId userId, required Email newEmail}) async {
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
  Future<void> updatePassword({required UserId userId, required Password newPassword}) async {
    final userPassword = _userPasswordDatabase.get(userId);
    if (userPassword != null) {
      _userPasswordDatabase.put(userId, newPassword);
    }
  }

  @override
  Future<void> delete({required UserId userId}) async {
    _userdatabase.delete(userId);
  }

  bool isPasswordVerified(
          {required UserId userId, required Password password}) =>
      _userPasswordDatabase.isPasswordVerified(userId, password);
}
