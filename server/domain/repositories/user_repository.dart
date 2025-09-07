import '../entities/user.dart';
import '../value_objects/email.dart';
import '../value_objects/id.dart';
import '../value_objects/password.dart';

abstract class UserRepository {
  List<User> get users;
  User? getById(Id id);
  User? getByEmail(Email email);
  void delete(Id id);
  void updateEmail(Id id, Email newEmail);
  void updatePassword(Id id, Password newPassword);
}