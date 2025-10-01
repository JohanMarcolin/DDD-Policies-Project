import 'dart:convert';
import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import '../utils/factories/test_server_factory.dart';
import '../utils/factories/test_user_entry_factory.dart';
import 'utils/test_token_utils.dart';

void main() {
  final tester = TestUserEntryFactory.defaultUserEntries.first;
  group('User Controller', () {
    late String accessToken;
    setUpAll(() async {
      await TestServerFactory.start();
      accessToken = await getAccessToken(testUserEntry: tester);
    });

    tearDownAll(() async {
      await TestServerFactory.stop();
    });

    group('Shall succeed', () {
      test('Get all users returns a list', () async {
        final response = await http.get(
          Uri.parse('${TestServerFactory.baseUrl}/user/all'),
          headers: getAuthHeader(accessToken),
        );
        expect(response.statusCode, 200);
        final data = jsonDecode(response.body);
        expect(data['data'], isNotNull);
        for (final user in data['data']) {
          expect(user['id'], isNotNull);
          expect(user['email'], isNotNull);
          expect(user['role'], isNotNull);
        }
      });

      test('Get user by id returns user', () async {
        final response = await http.get(
          Uri.parse('${TestServerFactory.baseUrl}/user/${tester.userId.value}'),
          headers: getAuthHeader(accessToken),
        );
        expect(response.statusCode, 200);
      });

      test('Update email returns success', () async {
        final response = await http.post(
          Uri.parse(
              '${TestServerFactory.baseUrl}/user/${tester.userId.value}/email'),
          headers: getAuthHeader(accessToken),
          body: jsonEncode({'newEmail': 'new@example.com'}),
        );
        expect(response.statusCode, equals(200));
      });

      test('Update password returns success', () async {
        final passwordPolicy = PasswordValidationPolicy();
        final password = passwordPolicy.generatePassword();
        final response = await http.post(
          Uri.parse(
              '${TestServerFactory.baseUrl}/user/${tester.userId.value}/password'),
          headers: getAuthHeader(accessToken),
          body: jsonEncode({'newPassword': password.value}),
        );
        expect(response.statusCode, equals(200));
      });

      test('Delete user returns success', () async {
        final response = await http.delete(
          Uri.parse('${TestServerFactory.baseUrl}/user/${tester.userId.value}'),
          headers: getAuthHeader(accessToken),
        );
        expect(response.statusCode, equals(200));
      });
    });

    group('Shall fail', () {
      test('Get user by id fails', () async {
        final response = await http.get(
          Uri.parse('${TestServerFactory.baseUrl}/user/${tester.userId.value}'),
          headers: getAuthHeader(accessToken),
        );
        expect(response.statusCode, 404);
      });

      test('Delete user fails', () async {
        final response = await http.delete(
          Uri.parse('${TestServerFactory.baseUrl}/user/${tester.userId.value}'),
          headers: getAuthHeader(accessToken),
        );
        expect(response.statusCode, equals(404));
      });

      test('Update email fails', () async {
        final response = await http.post(
          Uri.parse(
              '${TestServerFactory.baseUrl}/user/${tester.userId.value}/email'),
          headers: getAuthHeader(accessToken),
          body: jsonEncode({'newEmail': 'example.com'}),
        );
        expect(response.statusCode, equals(404));
      });

      test('Update password fails', () async {
        final response = await http.post(
          Uri.parse(
              '${TestServerFactory.baseUrl}/user/${tester.userId.value}/password'),
          headers: getAuthHeader(accessToken),
          body: jsonEncode({'newPassword': 'newpassword123'}),
        );
        expect(response.statusCode, equals(404));
      });
    });
  });
}
