import 'package:domain/entities/user.dart';
import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/password.dart';
import 'package:domain/value_objects/role.dart';
import 'package:error_codes/error_codes.dart';
import 'package:server/infrastructure/http/exceptions/request_exceptions.dart';
import 'package:shelf/shelf.dart';
import 'package:domain/value_objects/email.dart';
import 'package:shelf_router/shelf_router.dart';
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

  Map<String, dynamic> _userMap(User user, Password password) => {
        'userId': user.userId.value,
        'email': user.email.value,
        'role': user.role.name,
        'password': password.value,
      };

  Future<Response> createAllUserPairs(Request req) async {
    var userPairs = [];

    for (var role in Role.values) {
      final userEntry = await _createUserEntry(role: role);
      _userDatabase.put(userEntry.user.userId, userEntry.user);
      _userPasswordDatabase.put(userEntry.user.userId, userEntry.password);
      userPairs.add(_userMap(userEntry.user, userEntry.password));
    }
    return created(userPairs);
  }

  Future<Response> createUser(Request req) async {
    final roleNameParam = req.params['roleName'];

    if (roleNameParam == null || roleNameParam.isEmpty) {
      throw BadRequestException(PayloadMissingRole());
    }

    final role = Role.values.firstWhere(
      (role) => role.name.toLowerCase() == roleNameParam.toLowerCase(),
      orElse: () => Role.user,
    );

    final userEntry = await _createUserEntry(role: role);
    return created(_userMap(userEntry.user, userEntry.password));
  }

  Future<({User user, Password password})> _createUserEntry(
      {Role role = Role.user}) async {
    final userId = UserId.generate();
    final email = Email('${role.name}_${Uuid().v4().substring(0, 4)}@test.com');
    final user = User(email: email, userId: userId, role: role);
    final password = PasswordValidationPolicy.generatePassword();

    _userDatabase.put(user.userId, user);
    _userPasswordDatabase.put(user.userId, password);

    return (user: user, password: password);
  }

  Future<Response> deleteAllUsers(Request req) async {
    final users = _userDatabase.getAll();

    for (var user in users) {
      _userDatabase.delete(user.userId);
      _userPasswordDatabase.delete(user.userId);
    }

    return deleted();
  }

  Future<Response> deleteUser(Request req) async {
    final userId = extractUserIdFromParams(req);

    _userDatabase.delete(userId);
    _userPasswordDatabase.delete(userId);

    return deleted();
  }
}
