import '../entities/user.dart';
import '../../value_objects/email.dart';
import '../../value_objects/id.dart';
import '../../value_objects/password.dart';

abstract class UserRepository {
  Future<List<User>> get users;
  Future<User?> get({required UserId userId});
  Future<User?> getByEmail({required Email email});
  Future<void> delete({required UserId userId});
  Future<void> updateEmail({required UserId userId, required Email newEmail});
  Future<void> updatePassword({required UserId userId, required Password newPassword});
}
