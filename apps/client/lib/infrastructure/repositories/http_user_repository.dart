import 'package:client/infrastructure/apis/user_api.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/password.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/repositories/user_repository.dart' as domain;

/// Implementation of [domain.UserRepository] using [UserApi].
///
/// Delegates user CRUD operations to [UserApi].
class HttpUserRepository implements domain.UserRepository {
  HttpUserRepository({required UserApi userApi}) : _userApi = userApi;

  final UserApi _userApi;

  /// Deletes a user by [userId].
  ///
  /// Rethrows if the operation fails.
  @override
  Future<void> delete({required UserId userId}) async {
    try {
      await _userApi.delete(userId: userId);
    } catch (_) {
      rethrow;
    }
  }

  /// Retrieves a user by [userId].
  ///
  /// Returns the [User] if found, otherwise `null`. Rethrows if the operation fails.
  @override
  Future<User?> get({required UserId userId}) async {
    try {
      final user = await _userApi.get(userId: userId);
      return user;
    } catch (_) {
      rethrow;
    }
  }

  /// Retrieves a user by [email].
  ///
  /// Rethrows if the operation fails. Not yet implemented.
  ///
  /// Note: This method always throws [UnimplementedError].
  @override
  Future<User?> getByEmail({required Email email}) {
    throw UnimplementedError();
  }

  /// Updates the email of a user by [userId].
  ///
  /// Rethrows if the operation fails.
  @override
  Future<void> updateEmail({required UserId userId, required Email newEmail}) async {
    try {
      await _userApi.updateEmail(userId: userId, newEmail: newEmail);
    } catch (_) {
      rethrow;
    }
  }

  /// Updates the password of a user by [userId].
  ///
  /// Rethrows if the operation fails.
  @override
  Future<void> updatePassword({required UserId userId, required Password newPassword}) async {
    try {
      await _userApi.updatePassword(userId: userId, newPassword: newPassword);
    } catch (_) {
      rethrow;
    }
  }

  /// Retrieves all users.
  ///
  /// Returns a list of [User]:s. Rethrows if the operation fails.
  @override
  Future<List<User>> get users async {
    try {
      final users = await _userApi.users;
      return users;
    } catch (_) {
      rethrow;
    }
  }
}
