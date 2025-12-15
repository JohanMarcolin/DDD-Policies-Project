import 'dart:convert';
import 'package:api_error_codes/api_error_codes.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/policies/value_validation_policies/user_credentials/user_credential_policy.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/password.dart';
import 'package:domain/value_objects/role.dart';
import 'package:server/infrastructure/policy_registry.dart';
import 'package:test_utils/auth/auth_header.dart';
import 'package:test_utils/domain/user_administration_service.dart';
import 'package:test_utils/fixtures/server/test_server_fixture.dart';
import 'package:test_utils/fixtures/user/user_test_fixture.dart';
import 'api_test_server_fixture.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

void main() {
  final userAdministrationService = createStubbedUserAdministrationService();

  late UserTestFixture initiator;
  late List<UserTestFixture> initiators;
  late UserTestFixture target;

  setUp(() async {
    await ApiTestServerFixture.setup();
  });

  tearDown(() async {
    await ApiTestServerFixture.teardown();
  });

  group('User Controller', () {
    for (final initiatorRole in Role.values) {
      group('_getAllUsers', () {
        setUp(() async {
          initiators = await ApiTestServerFixture.createAllUserFixtures();
        });
        test('should get users authorized for viewing', () async {
          for (final initiator in initiators) {
            final response = await http.get(
              Uri.parse('${TestServerFixture.baseUrl}/user/all'),
              headers: await getAuthHeader(initiator),
            );
            final body = jsonDecode(response.body);

            expect(response.statusCode, 200);
            expect(body['isSuccess'], isTrue);
            final users = body['data'];

            for (final user in users) {
              final userId = UserId(user['userId']);
              final email = Email(user['email']);
              final role = Role.values.firstWhere((role) => role.name == user['role']);

              expect(userId, isNotNull);
              expect(email, isNotNull);
              expect(role, isNotNull);

              userAdministrationService.authorizeViewUser(
                initiator: initiator.user,
                target: User(userId: userId, email: email, role: role),
                onAuthorized: () {},
                onUnauthorized: (reason) {
                  fail('User ${initiator.user.role.name} is NOT authorized to see ${role.name}, reason: $reason');
                },
              );
            }
          }
        });
      });
      for (final targetRole in Role.values) {
        group('_getUserById', () {
          setUp(() async {
            initiator = await ApiTestServerFixture.createUserFixture(role: initiatorRole);
            target = await ApiTestServerFixture.createUserFixture(role: targetRole);
          });

          test('should get user by id if authorized, otherwise NOT', () async {
            final response = await http.get(
              Uri.parse('${TestServerFixture.baseUrl}/user/${target.userId.value}'),
              headers: await getAuthHeader(initiator),
            );
            final body = jsonDecode(response.body);

            userAdministrationService.authorizeViewUser(
                initiator: initiator.user,
                target: target.user,
                onAuthorized: () {
                  final user = body['data'];

                  expect(response.statusCode, 200);
                  expect(body['isSuccess'], isTrue);
                  expect(user['userId'], target.userId.value);
                  expect(user['email'], target.email.value);
                  expect(user['role'], target.user.role.name);
                },
                onUnauthorized: (reason) {
                  expect(response.statusCode, 403);
                  expect(body['isSuccess'], isFalse);
                  expect(body['policyViolationReason'], reason.toString());
                });
          });
        });

        group('_deleteUser', () {
          setUp(() async {
            initiator = await ApiTestServerFixture.createUserFixture(role: initiatorRole);
            target = await ApiTestServerFixture.createUserFixture(role: targetRole);
          });

          test('should delete user by id if authorized, otherwise NOT', () async {
            final response = await http.delete(
              Uri.parse('${TestServerFixture.baseUrl}/user/${target.userId.value}'),
              headers: await getAuthHeader(initiator),
            );
            final body = jsonDecode(response.body);

            userAdministrationService.authorizeDeleteUser(
                initiator: initiator.user,
                target: target.user,
                onAuthorized: () {
                  expect(body['isSuccess'], isTrue);
                  expect(response.statusCode, 200);
                },
                onUnauthorized: (reason) {
                  expect(response.statusCode, 403);
                  expect(body['isSuccess'], isFalse);
                  expect(body['policyViolationReason'], reason.toString());
                });
          });
        });

        group('_updateEmail', () {
          setUp(() async {
            initiator = await ApiTestServerFixture.createUserFixture(role: initiatorRole);
            target = await ApiTestServerFixture.createUserFixture(role: targetRole);
          });
          test('should update email with valid email if authorized, otherwise NOT', () async {
            final email = Email('valid@example.com');

            expect(PolicyRegistry.userEmailValidationPolicy.isValid(email), isTrue);
            final validEmail = email;

            final response = await http.put(
              Uri.parse('${TestServerFixture.baseUrl}/user/${target.userId.value}/email'),
              headers: await getAuthHeader(initiator),
              body: jsonEncode({'newEmail': validEmail.value}),
            );
            final body = jsonDecode(response.body);

            userAdministrationService.authorizeUpdateUserEmail(
                initiator: initiator.user,
                target: target.user,
                onAuthorized: () {
                  expect(body['isSuccess'], isTrue);
                  expect(response.statusCode, 200);
                },
                onUnauthorized: (reason) {
                  expect(response.statusCode, 403);
                  expect(body['isSuccess'], isFalse);
                  expect(body['policyViolationReason'], reason.toString());
                });
          });

          test('should NOT update email with invalid email', () async {
            final email = Email('invalid-email');

            expect(PolicyRegistry.userEmailValidationPolicy.isValid(email), isFalse);
            final invalidEmail = email;

            final response = await http.put(
              Uri.parse('${TestServerFixture.baseUrl}/user/${target.userId.value}/email'),
              headers: await getAuthHeader(initiator),
              body: jsonEncode({'newEmail': invalidEmail.value}),
            );
            final body = jsonDecode(response.body);

            userAdministrationService.authorizeUpdateUserEmail(
                initiator: initiator.user,
                target: target.user,
                onAuthorized: () {
                  expect(response.statusCode, 403);
                  expect(body['isSuccess'], isFalse);
                  expect(body['policyViolationReason'], EmailInvalidFormat().toString());
                },
                onUnauthorized: (reason) {
                  expect(response.statusCode, 403);
                  expect(body['isSuccess'], isFalse);
                  expect(body['policyViolationReason'], reason.toString());
                });
          });

          test('should NOT update email if new email is already taken by self', () async {
            final currentEmail = initiator.email;

            final response = await http.put(
              Uri.parse('${TestServerFixture.baseUrl}/user/${initiator.userId.value}/email'),
              headers: await getAuthHeader(initiator),
              body: jsonEncode({'newEmail': currentEmail.value}),
            );
            final body = jsonDecode(response.body);

            userAdministrationService.authorizeUpdateUserEmail(
                initiator: initiator.user,
                target: initiator.user,
                onAuthorized: () {
                  expect(response.statusCode, 409);
                  expect(body['isSuccess'], isFalse);
                  expect(body['apiErrorCode'], UpdateUserEmailTakenBySelf().toString());
                },
                onUnauthorized: (reason) {
                  expect(response.statusCode, 409);
                  expect(body['isSuccess'], isFalse);
                  expect(body['apiErrorCode'], reason.toString());
                });
          });

          test('should NOT update email if new email is already taken by other user', () async {
            final takenEmail = initiator.email;

            final response = await http.put(
              Uri.parse('${TestServerFixture.baseUrl}/user/${target.userId.value}/email'),
              headers: await getAuthHeader(initiator),
              body: jsonEncode({'newEmail': takenEmail.value}),
            );
            final body = jsonDecode(response.body);

            userAdministrationService.authorizeUpdateUserEmail(
                initiator: initiator.user,
                target: target.user,
                onAuthorized: () {
                  expect(response.statusCode, 409);
                  expect(body['isSuccess'], isFalse);
                  expect(body['apiErrorCode'], UpdateUserEmailTakenByOther().toString());
                },
                onUnauthorized: (_) {
                  expect(response.statusCode, 409);
                  expect(body['isSuccess'], isFalse);
                  expect(body['apiErrorCode'], UpdateUserEmailTakenByOther().toString());
                });
          });
        });

        group('_updatePassword', () {
          setUp(() async {
            initiator = await ApiTestServerFixture.createUserFixture(role: initiatorRole);
            target = await ApiTestServerFixture.createUserFixture(role: targetRole);
          });
          test('should update password with valid password if authorized, otherwise NOT', () async {
            final password = PolicyRegistry.userPasswordValidationPolicy.generateRandomPassword();

            expect(PolicyRegistry.userPasswordValidationPolicy.isValid(password), isTrue);
            final validPassword = password;

            final response = await http.put(
              Uri.parse('${TestServerFixture.baseUrl}/user/${target.userId.value}/password'),
              headers: await getAuthHeader(initiator),
              body: jsonEncode({'newPassword': validPassword.value}),
            );
            final body = jsonDecode(response.body);

            userAdministrationService.authorizeUpdateUserPassword(
                initiator: initiator.user,
                target: target.user,
                onAuthorized: () {
                  expect(body['isSuccess'], isTrue);
                  expect(response.statusCode, 200);
                },
                onUnauthorized: (reason) {
                  expect(response.statusCode, 403);
                  expect(body['isSuccess'], isFalse);
                  expect(body['policyViolationReason'], reason.toString());
                });
          });

          test('should NOT update password with invalid password', () async {
            final password = Password('short');

            expect(UserPasswordValidationPolicy().isValid(password), isFalse);
            final invalidPassword = password;

            final response = await http.put(
              Uri.parse('${TestServerFixture.baseUrl}/user/${target.userId.value}/password'),
              headers: await getAuthHeader(initiator),
              body: jsonEncode({'newPassword': invalidPassword.value}),
            );
            final body = jsonDecode(response.body);

            userAdministrationService.authorizeUpdateUserPassword(
                initiator: initiator.user,
                target: target.user,
                onAuthorized: () {
                  expect(response.statusCode, 403);
                  expect(body['isSuccess'], isFalse);
                  expect(body['policyViolationReason'], PasswordTooShort().toString());
                },
                onUnauthorized: (reason) {
                  expect(response.statusCode, 403);
                  expect(body['isSuccess'], isFalse);
                  expect(body['policyViolationReason'], reason.toString());
                });
          });
        });
      }
    }
  });
}
