import '../entities/admin.dart';
import '../entities/super_admin.dart';
import '../entities/user.dart';
import '../value_objects/email.dart';
import '../value_objects/id.dart';
import '../value_objects/password.dart';
import '../value_objects/role.dart';

abstract class UserRepository {
  User? getById(Id id);
  User? getByEmail(Email email);
  List<User> get users;
  List<Admin> get admins;
  List<SuperAdmin> get superAdmins;
  void create(Email email, Password password, Role role);
  void delete(Id id);
  void updateEmail(Id id, Email newEmail);
  void updatePassword(Id id, Password newPassword);
}