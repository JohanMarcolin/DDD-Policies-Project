import 'package:dart_server/domain/entities/admin.dart';
import 'package:dart_server/domain/entities/super_admin.dart';
import 'package:dart_server/domain/entities/user.dart';
import 'package:dart_server/domain/value_objects/email.dart';
import 'package:dart_server/domain/value_objects/id.dart';
import 'package:dart_server/domain/value_objects/password.dart';

abstract class UserRepository {
  List<User> get users;
  List<Admin> get admins;
  List<SuperAdmin> get superAdmins;
  void create(Email email, Password password);
  void delete(Id id);
  void updateEmail(Id id, Email newEmail);
  void updatePassword(Id id, Password newPassword);
}