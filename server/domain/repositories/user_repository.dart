import '../entities/user.dart';
import '../value_objects/email.dart';
import '../value_objects/id.dart';
import '../value_objects/password.dart';
import '../value_objects/role.dart';
abstract class UserRepository {
  List<User> get users;
  User? get({required Id id});
  User? getByEmail({required Email email});
  void delete({required Id id});
  void updateEmail({required Id id, required Email newEmail});
  void updatePassword({required Id id, required Password newPassword});
}