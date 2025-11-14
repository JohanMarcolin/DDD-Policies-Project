import 'dart:convert';
import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/password.dart';
import 'package:domain/value_objects/role.dart';
import 'package:global_utils/test_server_fixture.dart';
import 'package:global_utils/user_test_fixture.dart';
import 'package:server/test/api/api_test_server_fixture.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import 'utils/test_token_utils.dart';

void main() {
  late UserTestFixture initiator;
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
          initiator = await ApiTestServerFixture.createUserFixture(role: initiatorRole);
        });
        test('should get users authorized for viewing', () async {
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

            expect(ViewUserPolicy().authorize(initiator.user, User(userId: userId, email: email, role: role)),
                isA<Authorized>());
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
            final viewUser = ViewUserPolicy().authorize(initiator.user, target.user);
            final response = await http.get(
              Uri.parse('${TestServerFixture.baseUrl}/user/${target.userId.value}'),
              headers: await getAuthHeader(initiator),
            );
            final body = jsonDecode(response.body);

            switch (viewUser) {
              case Authorized():
                final user = body['data'];

                expect(response.statusCode, 200);
                expect(body['isSuccess'], isTrue);
                expect(user['userId'], target.userId.value);
                expect(user['email'], target.email.value);
                expect(user['role'], target.user.role.name);

              case Unauthorized(:final reason):
                expect(response.statusCode, 403);
                expect(body['isSuccess'], isFalse);
                expect(body['policyViolationDetails'], reason.toString());
            }
          });
        });

        group('_deleteUser', () {
          setUp(() async {
            initiator = await ApiTestServerFixture.createUserFixture(role: initiatorRole);
            target = await ApiTestServerFixture.createUserFixture(role: targetRole);
          });

          test('should delete user by id if authorized, otherwise NOT', () async {
            final deleteUser = DeleteUserPolicy().authorize(initiator.user, target.user);
            final response = await http.delete(
              Uri.parse('${TestServerFixture.baseUrl}/user/${target.userId.value}'),
              headers: await getAuthHeader(initiator),
            );
            final body = jsonDecode(response.body);

            switch (deleteUser) {
              case Authorized():
                expect(body['isSuccess'], isTrue);
                expect(response.statusCode, 200);
              case Unauthorized(:final reason):
                expect(response.statusCode, 403);
                expect(body['isSuccess'], isFalse);
                expect(body['policyViolationDetails'], reason.toString());
            }
          });
        });

        group('_updateEmail', () {
          setUp(() async {
            initiator = await ApiTestServerFixture.createUserFixture(role: initiatorRole);
            target = await ApiTestServerFixture.createUserFixture(role: targetRole);
          });
          test('should update email with valid email if authorized, otherwise NOT', () async {
            final updateUserEmail = UpdateUserEmailPolicy().authorize(initiator.user, target.user);
            final email = Email('valid@example.com');

            expect(EmailValidationPolicy().isValid(email), isTrue);
            final validEmail = email;

            final response = await http.put(
              Uri.parse('${TestServerFixture.baseUrl}/user/${target.userId.value}/email'),
              headers: await getAuthHeader(initiator),
              body: jsonEncode({'newEmail': validEmail.value}),
            );
            final body = jsonDecode(response.body);

            switch (updateUserEmail) {
              case Authorized():
                expect(body['isSuccess'], isTrue);
                expect(response.statusCode, 200);
              case Unauthorized(:final reason):
                expect(response.statusCode, 403);
                expect(body['isSuccess'], isFalse);
                expect(body['policyViolationDetails'], reason.toString());
            }
          });

          test('should NOT update email with invalid email', () async {
            final updateUserEmail = UpdateUserEmailPolicy().authorize(initiator.user, target.user);
            final email = Email('invalid-email');

            expect(EmailValidationPolicy().isValid(email), isFalse);
            final invalidEmail = email;

            final response = await http.put(
              Uri.parse('${TestServerFixture.baseUrl}/user/${target.userId.value}/email'),
              headers: await getAuthHeader(initiator),
              body: jsonEncode({'newEmail': invalidEmail.value}),
            );
            final body = jsonDecode(response.body);

            switch (updateUserEmail) {
              case Authorized():
              case Unauthorized():
                expect(response.statusCode, 403);
                expect(body['isSuccess'], isFalse);
                expect(body['policyViolationDetails'], EmailInvalidFormat().toString());
            }
          });
        });

        group('_updatePassword', () {
          setUp(() async {
            initiator = await ApiTestServerFixture.createUserFixture(role: initiatorRole);
            target = await ApiTestServerFixture.createUserFixture(role: targetRole);
          });
          test('should update password with valid password if authorized, otherwise NOT', () async {
            final updateUserPassword = UpdateUserPasswordPolicy().authorize(initiator.user, target.user);
            final password = PasswordValidationPolicy.generatePassword();

            expect(PasswordValidationPolicy().isValid(password), isTrue);
            final validPassword = password;

            final response = await http.put(
              Uri.parse('${TestServerFixture.baseUrl}/user/${target.userId.value}/password'),
              headers: await getAuthHeader(initiator),
              body: jsonEncode({'newPassword': validPassword.value}),
            );
            final body = jsonDecode(response.body);

            switch (updateUserPassword) {
              case Authorized():
                expect(body['isSuccess'], isTrue);
                expect(response.statusCode, 200);
              case Unauthorized(:final reason):
                expect(response.statusCode, 403);
                expect(body['isSuccess'], isFalse);
                expect(body['policyViolationDetails'], reason.toString());
            }
          });

          test('should NOT update password with invalid password', () async {
            final updateUserPassword = UpdateUserPasswordPolicy().authorize(initiator.user, target.user);
            final password = Password('short');

            expect(PasswordValidationPolicy().isValid(password), isFalse);
            final invalidPassword = password;

            final response = await http.put(
              Uri.parse('${TestServerFixture.baseUrl}/user/${target.userId.value}/password'),
              headers: await getAuthHeader(initiator),
              body: jsonEncode({'newPassword': invalidPassword.value}),
            );
            final body = jsonDecode(response.body);

            switch (updateUserPassword) {
              case Authorized():
              case Unauthorized():
                expect(response.statusCode, 403);
                expect(body['isSuccess'], isFalse);
                expect(body['policyViolationDetails'], PasswordTooShort().toString());
            }
          });
        });
      }
    }
  });
}
