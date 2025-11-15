import 'package:domain/entities/user.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/password.dart';
import 'package:domain/value_objects/role.dart';

class UserTestFixture {
  UserTestFixture({required this.user, required this.password});

  final User user;
  final Password password;

  UserId get userId => user.userId;
  Email get email => user.email;
  Role get role => user.role;
}
