import 'package:domain/entities/user.dart';
import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/password.dart';
import 'package:domain/value_objects/role.dart';
import 'package:global_utils/error_codes.dart';
import 'package:server/infrastructure/http/exceptions/request_exceptions.dart';
import 'package:shelf/shelf.dart';
import 'package:domain/value_objects/email.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';

import '../databases/in_memory_user_database.dart';
import '../databases/in_memory_user_password_database.dart';
import '../http/response_utils.dart';

/// Service for managing [UserTestFixture]s and related operations.
class TestService {
  TestService({
    required InMemoryUserDatabase userDatabase,
    required InMemoryUserPasswordDatabase userPasswordDatabase,
  })  : _userDatabase = userDatabase,
        _userPasswordDatabase = userPasswordDatabase;

  final InMemoryUserDatabase _userDatabase;
  final InMemoryUserPasswordDatabase _userPasswordDatabase;

  Map<String, dynamic> _userFixtureMap(User user, Password password) => {
        'userId': user.userId.value,
        'email': user.email.value,
        'role': user.role.name,
        'password': password.value,
      };

  /// Creates user fixtures for all [Role.values] and returns them in the response.
  ///
  /// Returns a list of user fixture maps.
  Future<Response> createAllUserFixtures(Request req) async {
    try {
      var userFixtures = [];
      for (final role in Role.values) {
        final fixture = await _createUserFixture(role: role);
        userFixtures.add(_userFixtureMap(fixture.user, fixture.password));
      }
      return created(userFixtures);
    } catch (e) {
      rethrow;
    }
  }

  /// Creates a [UserTestFixture] for the specified [Role] and returns it in the response.
  ///
  /// Throws [BadRequestException] if the role parameter is missing or invalid.
  Future<Response> createUserFixture(Request req) async {
    try {
      final roleNameParam = req.params['roleName'];
      if (roleNameParam == null || roleNameParam.isEmpty) {
        throw BadRequestException(PayloadMissingRole());
      }
      final role = Role.values.firstWhere(
        (role) => role.name.toLowerCase() == roleNameParam.toLowerCase(),
        orElse: () => Role.user,
      );
      final userFixture = await _createUserFixture(role: role);
      return created(_userFixtureMap(userFixture.user, userFixture.password));
    } catch (e) {
      rethrow;
    }
  }

  Future<({User user, Password password})> _createUserFixture({Role role = Role.user}) async {
    final userId = UserId.generate();
    final email = Email('${role.name}_${Uuid().v4().substring(0, 4)}@test.com');
    final user = User(email: email, userId: userId, role: role);
    final password = PasswordValidationPolicy.generatePassword();

    _userDatabase.put(user.userId, user);
    _userPasswordDatabase.put(user.userId, password);

    return (user: user, password: password);
  }

  /// Deletes all [UserTestFixtures]s from the in-memory databases.
  ///
  /// Returns a 204 Deleted response after successful deletion.
  Future<Response> deleteAllUserFixtures(Request req) async {
    final users = await _userDatabase.getAll();
    for (final user in users) {
      await _userDatabase.delete(user.userId);
      await _userPasswordDatabase.delete(user.userId);
    }
    return deleted();
  }
}
