import 'package:domain/entities/user.dart';
import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:domain/value_objects/id.dart';
import 'package:shelf/shelf.dart';
import 'package:domain/value_objects/email.dart';
import 'package:uuid/uuid.dart';

import '../databases/user_database.dart';
import '../databases/user_password_database.dart';
import '../http/request_utils.dart';
import '../http/response_utils.dart';

class TestService {
  TestService({
    required UserDatabase userDatabase,
    required UserPasswordDatabase userPasswordDatabase,
  })  : _userDatabase = userDatabase,
        _userPasswordDatabase = userPasswordDatabase;

  final UserDatabase _userDatabase;
  final UserPasswordDatabase _userPasswordDatabase;

  Future<Response> createUser(Request req) async {
    final userId = UserId.generate();
    final email = Email('${Uuid().v4().substring(0, 8)}@test.com');

    final testUser = User(email: email, userId: userId);
    final password = PasswordValidationPolicy.generatePassword();

    _userDatabase.put(testUser.userId, testUser);
    _userPasswordDatabase.put(testUser.userId, password);

    return ok({
      'userId': testUser.userId.value,
      'email': testUser.email.value,
      'role': testUser.role.name,
      'password': password.value,
    });
  }

  Future<Response> deleteUser(Request req) async {
    final userId = extractUserIdFromParams(req);

    _userDatabase.delete(userId);
    _userPasswordDatabase.delete(userId);

    return deleted();
  }
}
