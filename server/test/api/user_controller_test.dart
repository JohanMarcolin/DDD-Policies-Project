import 'dart:convert';
import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:domain/value_objects/role.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import '../utils/factories/test_server_factory.dart';
import '../utils/factories/test_user_entry_factory.dart';
import 'utils/test_token_utils.dart';

void main() {
  final userEntries = TestUserEntryFactory.defaultUserEntries;
  final users = userEntries.where((e) => e.user.role.name == 'user').toList();
  final admins = userEntries.where((e) => e.user.role.name == 'admin').toList();
  final analysts =
      userEntries.where((e) => e.user.role.name == 'analyst').toList();

  Future<String> getToken(TestUserEntry entry) async =>
      await getAccessToken(testUserEntry: entry);

  group('User Controller', () {
    setUpAll(() async {
      await TestServerFactory.start();
    });

    tearDownAll(() async {
      await TestServerFactory.stop();
    });

    for (final initiator in [...users]) {
      group('As ${initiator.user.role.name} (${initiator.userId.value})', () {
        late String accessToken;
        setUpAll(() async {
          accessToken = await getToken(initiator);
        });

        for (final target in userEntries) {
          group('Target: ${target.user.role.name} (${target.userId.value})',
              () {
            test('View user', () async {
              final response = await http.get(
                Uri.parse(
                    '${TestServerFactory.baseUrl}/user/${target.userId.value}'),
                headers: getAuthHeader(accessToken),
              );
              switch (initiator.user.role) {
                case Role.analyst:
                  expect(response.statusCode, 200);
                  break;
                case Role.admin:
                case Role.user:
                  if (target.user.role == Role.analyst) {
                    expect(response.statusCode, 403);
                    final body = jsonDecode(response.body);
                    expect(body['policyViolationDetails'],
                        equals('CannotViewAnalyst'));
                  } else {
                    expect(response.statusCode, 200);
                  }
                  break;
              }
            });
/*
            test('Update email', () async {
              final response = await http.put(
                Uri.parse(
                    '${TestServerFactory.baseUrl}/user/${target.userId.value}/email'),
                headers: getAuthHeader(accessToken),
                body: jsonEncode({'newEmail': 'new@example.com'}),
              );
              // Policy logic for update email
              if (initiator.user.role.name == 'analyst') {
                expect(response.statusCode, 200);
              } else if (initiator.user.role.name == 'admin') {
                if (target.user.role.name == 'analyst') {
                  expect(response.statusCode, 403);
                  final body = jsonDecode(response.body);
                  expect(
                      body['errorCode'], equals('CannotUpdateEmailOnAnalyst'));
                } else {
                  expect(response.statusCode, 200);
                }
              } else if (initiator.user.role.name == 'user') {
                if (initiator.userId.value == target.userId.value) {
                  expect(response.statusCode, 200);
                } else {
                  expect(response.statusCode, 403);
                  final body = jsonDecode(response.body);
                  expect(body['errorCode'], equals('CanOnlyUpdateEmailOnSelf'));
                }
              }
            });

            test('Update password', () async {
              final passwordPolicy = PasswordValidationPolicy();
              final password = passwordPolicy.generatePassword();
              final response = await http.put(
                Uri.parse(
                    '${TestServerFactory.baseUrl}/user/${target.userId.value}/password'),
                headers: getAuthHeader(accessToken),
                body: jsonEncode({'newPassword': password.value}),
              );
              // Policy logic for update password
              if (initiator.user.role.name == 'analyst') {
                expect(response.statusCode, 200);
              } else if (initiator.user.role.name == 'admin') {
                if (target.user.role.name == 'analyst') {
                  expect(response.statusCode, 403);
                  final body = jsonDecode(response.body);
                  expect(body['errorCode'],
                      equals('CannotUpdatePasswordOnAnalyst'));
                } else {
                  expect(response.statusCode, 200);
                }
              } else if (initiator.user.role.name == 'user') {
                if (initiator.userId.value == target.userId.value) {
                  expect(response.statusCode, 200);
                } else {
                  expect(response.statusCode, 403);
                  final body = jsonDecode(response.body);
                  expect(
                      body['errorCode'], equals('CanOnlyUpdatePasswordOnSelf'));
                }
              }
            });

            test('Delete user', () async {
              final response = await http.delete(
                Uri.parse(
                    '${TestServerFactory.baseUrl}/user/${target.userId.value}'),
                headers: getAuthHeader(accessToken),
              );
              // Policy logic for delete
              if (initiator.user.role.name == 'analyst') {
                if (initiator.userId.value == target.userId.value) {
                  expect(response.statusCode, 204);
                } else {
                  expect(response.statusCode, 403);
                  final body = jsonDecode(response.body);
                  expect(body['errorCode'], equals('CanOnlyDeleteSelf'));
                }
              } else if (initiator.user.role.name == 'admin') {
                if (target.user.role.name == 'analyst') {
                  expect(response.statusCode, 403);
                  final body = jsonDecode(response.body);
                  expect(body['errorCode'], equals('CannotDeleteAnalyst'));
                } else {
                  expect(response.statusCode, 204);
                }
              } else if (initiator.user.role.name == 'user') {
                if (initiator.userId.value == target.userId.value) {
                  expect(response.statusCode, 204);
                } else {
                  expect(response.statusCode, 403);
                  final body = jsonDecode(response.body);
                  expect(body['errorCode'], equals('CanOnlyDeleteSelf'));
                }
              }
            });
            */
          });
        }
      });
    }
  });
}
