import 'dart:convert';
import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/password.dart';
import 'package:domain/value_objects/role.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import '../utils/factories/test_server_factory.dart';
import '../utils/factories/test_user_entry_factory.dart';
import 'utils/test_token_utils.dart';

void main() {
  final userEntries = UserEntryFactory.defaultUserEntries;

  Future<String> getToken(UserEntry entry) async =>
      await getAccessToken(userEntry: entry);

  group('User Controller', () {
    for (final initiator in userEntries) {
      final initiatorUserRole = '{${initiator.user.role.name}}';

      for (final target in userEntries) {
        final targetUserRole = '{${target.user.role.name}}';

        group(
            initiator.user.isSameAs(target.user)
                ? '$initiatorUserRole acting on self'
                : '$initiatorUserRole acting on $targetUserRole', () {
          late String accessToken;

          setUp(() async {
            await TestServerFactory.start(includeDefaultUsers: true);
            accessToken = await getToken(initiator);
          });

          tearDown(() async {
            await TestServerFactory.stop();
          });

          group('_getAllUsers', () {
            test('should get users authorized for viewing', () async {
              final response = await http.get(
                Uri.parse('${TestServerFactory.baseUrl}/user/all'),
                headers: getAuthHeader(accessToken),
              );
              final body = jsonDecode(response.body);

              expect(response.statusCode, 200);
              expect(body['isSuccess'], isTrue);
              final users = body['data'];

              for (final user in users) {
                final userId = UserId(user['userId']);
                final email = Email(user['email']);
                final role =
                    Role.values.firstWhere((role) => role.name == user['role']);

                expect(userId, isNotNull);
                expect(email, isNotNull);
                expect(role, isNotNull);

                expect(
                    ViewUserPolicy().authorize(initiator.user,
                        User(userId: userId, email: email, role: role)),
                    isA<Authorized>());
              }
            });
          });

          group('_getUserById', () {
            final canViewUser =
                ViewUserPolicy().authorize(initiator.user, target.user);
            test(
                'should ${canViewUser.isAuthorized ? '' : 'NOT'} get user by id',
                () async {
              final response = await http.get(
                Uri.parse(
                    '${TestServerFactory.baseUrl}/user/${target.userId.value}'),
                headers: getAuthHeader(accessToken),
              );
              final body = jsonDecode(response.body);

              switch (canViewUser) {
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
            final canDeleteUser =
                DeleteUserPolicy().authorize(initiator.user, target.user);
            test(
                'should ${canDeleteUser.isAuthorized ? '' : 'NOT'} delete user by id',
                () async {
              final response = await http.delete(
                Uri.parse(
                    '${TestServerFactory.baseUrl}/user/${target.userId.value}'),
                headers: getAuthHeader(accessToken),
              );
              final body = jsonDecode(response.body);

              switch (canDeleteUser) {
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
            final canUpdateEmail =
                UpdateUserEmailPolicy().authorize(initiator.user, target.user);
            test(
                'should ${canUpdateEmail.isAuthorized ? '' : 'NOT'} update email with valid email',
                () async {
              final email = Email('valid@example.com');

              expect(EmailValidationPolicy().isValid(email), isTrue);
              final validEmail = email;

              final response = await http.put(
                Uri.parse(
                    '${TestServerFactory.baseUrl}/user/${target.userId.value}/email'),
                headers: getAuthHeader(accessToken),
                body: jsonEncode({'newEmail': validEmail.value}),
              );
              final body = jsonDecode(response.body);

              switch (canUpdateEmail) {
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
              final email = Email('invalid-email');

              expect(EmailValidationPolicy().isValid(email), isFalse);
              final invalidEmail = email;

              final response = await http.put(
                Uri.parse(
                    '${TestServerFactory.baseUrl}/user/${target.userId.value}/email'),
                headers: getAuthHeader(accessToken),
                body: jsonEncode({'newEmail': invalidEmail.value}),
              );
              final body = jsonDecode(response.body);

              switch (canUpdateEmail) {
                case Authorized():
                case Unauthorized():
                  expect(response.statusCode, 403);
                  expect(body['isSuccess'], isFalse);
                  expect(body['policyViolationDetails'],
                      EmailInvalidFormat().toString());
              }
            });
          });

          group('_updatePassword', () {
            final canUpdatePassword = UpdateUserPasswordPolicy()
                .authorize(initiator.user, target.user);
            test(
                'should ${canUpdatePassword.isAuthorized ? '' : 'NOT'} update password with valid password',
                () async {
              final password = PasswordValidationPolicy.generatePassword();

              expect(PasswordValidationPolicy().isValid(password), isTrue);
              final validPassword = password;

              final response = await http.put(
                Uri.parse(
                    '${TestServerFactory.baseUrl}/user/${target.userId.value}/password'),
                headers: getAuthHeader(accessToken),
                body: jsonEncode({'newPassword': validPassword.value}),
              );
              final body = jsonDecode(response.body);

              switch (canUpdatePassword) {
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
              final password = Password('short');

              expect(PasswordValidationPolicy().isValid(password), isFalse);
              final invalidPassword = password;

              final response = await http.put(
                Uri.parse(
                    '${TestServerFactory.baseUrl}/user/${target.userId.value}/password'),
                headers: getAuthHeader(accessToken),
                body: jsonEncode({'newPassword': invalidPassword.value}),
              );
              final body = jsonDecode(response.body);

              switch (canUpdatePassword) {
                case Authorized():
                case Unauthorized():
                  expect(response.statusCode, 403);
                  expect(body['isSuccess'], isFalse);
                  expect(body['policyViolationDetails'],
                      PasswordTooShort().toString());
              }
            });
          });
        });
      }
    }
  });
}
