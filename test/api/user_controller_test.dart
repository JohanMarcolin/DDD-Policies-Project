import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;
import '../test_data_factories/test_server_factory.dart';
import '../test_data_factories/test_user_entry_factory.dart';
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
        expect(data['result'], isNotNull);
        for (final user in data['result']) {
          print(user);
          expect(user['id'], isNotNull);
          expect(user['email'], isNotNull);
          expect(user['role'], isNotNull);
        }
      });

      test('Get user by id returns user', () async {
        print(tester.user.id.value);
        final response = await http.get(
          Uri.parse(
              '${TestServerFactory.baseUrl}/user/${tester.user.id.value}'),
          headers: getAuthHeader(accessToken),
        );
        expect(response.statusCode, 200);
      });

      test('Update email returns success', () async {
        final response = await http.post(
          Uri.parse(
              '${TestServerFactory.baseUrl}/user/${tester.id.value}/email'),
          headers: getAuthHeader(accessToken),
          body: jsonEncode({'newEmail': 'new@example.com'}),
        );
        expect(response.statusCode, equals(200));
      });

      test('Update password returns success', () async {
        final response = await http.post(
          Uri.parse(
              '${TestServerFactory.baseUrl}/user/${tester.id.value}/password'),
          headers: getAuthHeader(accessToken),
          body: jsonEncode({'newPassword': 'hello'}),
        );
        expect(response.statusCode, equals(200));
      });

      test('Delete user returns success', () async {
        final response = await http.delete(
          Uri.parse('${TestServerFactory.baseUrl}/user/${tester.id.value}'),
          headers: getAuthHeader(accessToken),
        );
        expect(response.statusCode, equals(200));
      });
    });

    group('Shall fail', () {
      test('Get user by id fails', () async {
        print(tester.user.id.value);
        final response = await http.get(
          Uri.parse(
              '${TestServerFactory.baseUrl}/user/${tester.user.id.value}'),
          headers: getAuthHeader(accessToken),
        );
        expect(response.statusCode, 404);
      });

      test('Delete user fails', () async {
        final response = await http.delete(
          Uri.parse('${TestServerFactory.baseUrl}/user/${tester.id.value}'),
          headers: getAuthHeader(accessToken),
        );
        expect(response.statusCode, equals(404));
      });

      test('Update email fails', () async {
        final response = await http.post(
          Uri.parse(
              '${TestServerFactory.baseUrl}/user/${tester.id.value}/email'),
          headers: getAuthHeader(accessToken),
          body: jsonEncode({'newEmail': 'example.com'}),
        );
        expect(response.statusCode, equals(404));
      });

      test('Update password fails', () async {
        final response = await http.post(
          Uri.parse(
              '${TestServerFactory.baseUrl}/user/${tester.id.value}/password'),
          headers: getAuthHeader(accessToken),
          body: jsonEncode({'newPassword': 'newpassword123'}),
        );
        expect(response.statusCode, equals(404));
      });
    });
  });
}
