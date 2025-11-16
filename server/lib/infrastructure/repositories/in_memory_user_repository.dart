import 'package:domain/entities/user.dart';
import 'package:domain/repositories/user_repository.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/password.dart';
import 'package:global_utils/error_codes.dart';
import '../databases/user_database.dart';
import '../databases/user_password_database.dart';
import '../http/exceptions/request_exceptions.dart';
import '../http/exceptions/request_exceptions.dart' show NotFoundException, ServerErrorException;

class InMemoryUserRepository implements UserRepository {
  InMemoryUserRepository({
    required UserDatabase userDatabase,
    required UserPasswordDatabase userPasswordDatabase,
  })  : _userdatabase = userDatabase,
        _userPasswordDatabase = userPasswordDatabase;

  final UserDatabase _userdatabase;
  final UserPasswordDatabase _userPasswordDatabase;

  @override
  Future<List<User>> get users async {
    try {
      return _userdatabase.getAll();
    } catch (e) {
      throw ServerErrorException(UserRepoFailedToFetchUsers());
    }
  }

  @override
  Future<User?> get({required UserId userId}) async {
    try {
      return _userdatabase.get(userId);
    } catch (e) {
      throw ServerErrorException(UserRepoFailedToFetchUser());
    }
  }

  @override
  Future<User?> getByEmail({required Email email}) async {
    try {
      final users = await _userdatabase.getAll();
      final user = users.where((user) => user.email.value == email.value).toList();
      return user.isNotEmpty ? user.first : null;
    } catch (e) {
      throw ServerErrorException(UserRepoFailedToFetchUserByEmail());
    }
  }

  @override
  Future<void> updateEmail({required UserId userId, required Email newEmail}) async {
    try {
      final user = await _userdatabase.get(userId);
      if (user == null) {
        throw NotFoundException(UserRepoUserNotFoundById());
      }
      final updated = User(
        userId: user.userId,
        email: newEmail,
        role: user.role,
      );
      _userdatabase.put(userId, updated);
    } catch (e) {
      throw ServerErrorException(UserRepoFailedToUpdateEmail());
    }
  }

  @override
  Future<void> updatePassword({required UserId userId, required Password newPassword}) async {
    try {
      _userPasswordDatabase.put(userId, newPassword);
    } catch (e) {
      throw ServerErrorException(UserRepoFailedToUpdatePassword());
    }
  }

  @override
  Future<void> delete({required UserId userId}) async {
    try {
      _userdatabase.delete(userId);
    } catch (e) {
      throw ServerErrorException(UserRepoFailedToDeleteUser());
    }
  }
}
