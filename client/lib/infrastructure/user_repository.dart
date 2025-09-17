import 'package:client/infrastructure/apis/user_api.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/password.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/repositories/user_repository.dart' as domain;

class UserRepository implements domain.UserRepository {
  UserRepository(this.userApi);

  final UserApi userApi;

  @override
  Future<void> delete({required UserId userId}) async {
    try {
      await userApi.delete(userId: userId);
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<User?> get({required UserId userId}) async {
    try {
      final user = await userApi.get(userId: userId);
      return user;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<User?> getByEmail({required Email email}) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateEmail({
    required UserId userId,
    required Email newEmail,
  }) async {
    try {
      await userApi.updateEmail(userId: userId, newEmail: newEmail);
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> updatePassword({
    required UserId userId,
    required Password newPassword,
  }) async {
    try {
      await userApi.updatePassword(userId: userId, newPassword: newPassword);
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<List<User>> get users async {
    try {
      final users = await userApi.users;
      return users;
    } catch (_) {
      rethrow;
    }
  }
}
