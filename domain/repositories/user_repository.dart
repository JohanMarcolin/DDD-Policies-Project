import '../entities/user.dart';
import '../value_objects/email.dart';
import '../value_objects/id.dart';
import '../value_objects/password.dart';

abstract class UserRepository {
  List<User> get users;
  User? get({required UserId userId});
  User? getByEmail({required Email email});
  void delete({required UserId userId});
  void updateEmail({required UserId userId, required Email newEmail});
  void updatePassword({required UserId userId, required Password newPassword});
}
