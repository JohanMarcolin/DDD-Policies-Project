import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

import '../test_data_factories/test_server_factory.dart';
import '../test_data_factories/test_user_entry_factory.dart';

void main() {
  final testEntries = TestUserEntryFactory.defaultUserEntries;

  setUpAll(() async {
    await TestServerFactory.start();
  });

  tearDownAll(() async {
    await TestServerFactory.stop();
  });

  group('Auth Controller', () {
    group('Shall succeed', () {
      for (final testEntry in testEntries) {
        test('Login returns tokens for valid {$testEntry} credentials',
            () async {
          final response = await http.post(
            Uri.parse('${TestServerFactory.baseUrl}/auth/login'),
            body: jsonEncode({
              'email': testEntry.email.value,
              'password': testEntry.password.value
            }),
          );

          expect(response.statusCode, 200);

          final data = jsonDecode(response.body);
          final accessToken = data['result']['accessToken'];
          final refreshToken = data['result']['refreshToken'];

          expect(accessToken, isNotNull);
          expect(refreshToken, isNotNull);
        });
      }

      for (final testEntry in testEntries) {
        test('Refresh returns new access token', () async {
          final loginResponse = await http.post(
            Uri.parse('${TestServerFactory.baseUrl}/auth/login'),
            body: jsonEncode({
              'email': testEntry.email.value,
              'password': testEntry.password.value
            }),
          );

          final loginData = jsonDecode(loginResponse.body);
          final refreshToken = loginData['result']['refreshToken'];

          final refreshResponse = await http.post(
            Uri.parse('${TestServerFactory.baseUrl}/auth/refresh'),
            body: jsonEncode({'refreshToken': refreshToken}),
          );

          expect(refreshResponse.statusCode, equals(200));

          final refreshData = jsonDecode(refreshResponse.body);

          expect(refreshData['result']['accessToken'], isNotNull);
        });
      }
    });

    group('Shall fail', () {
      test('Login fails for invalid credentials', () async {
        final response = await http.post(
          Uri.parse('${TestServerFactory.baseUrl}/auth/login'),
          body: jsonEncode(
              {'email': testEntries.first.email.value, 'password': 'wrong'}),
        );
        expect(response.statusCode, equals(403));
      });
    });

    group('Login input validation', () {
      test('Empty request body returns 400', () async {
        final response = await http.post(
          Uri.parse('${TestServerFactory.baseUrl}/auth/login'),
          body: '',
        );
        expect(response.statusCode, 400);
      });

      test('Missing email field returns 400', () async {
        final response = await http.post(
          Uri.parse('${TestServerFactory.baseUrl}/auth/login'),
          body: jsonEncode({'password': testEntries.first.password.value}),
        );
        expect(response.statusCode, 400);
      });

      test('Empty email returns 400', () async {
        final response = await http.post(
          Uri.parse('${TestServerFactory.baseUrl}/auth/login'),
          body: jsonEncode(
              {'email': '', 'password': testEntries.first.password.value}),
        );
        expect(response.statusCode, 400);
      });

      test('Missing password field returns 400', () async {
        final response = await http.post(
          Uri.parse('${TestServerFactory.baseUrl}/auth/login'),
          body: jsonEncode({'email': testEntries.first.email.value}),
        );
        expect(response.statusCode, 400);
      });

      test('Empty password returns 400', () async {
        final response = await http.post(
          Uri.parse('${TestServerFactory.baseUrl}/auth/login'),
          body: jsonEncode(
              {'email': testEntries.first.email.value, 'password': ''}),
        );
        expect(response.statusCode, 400);
      });
    });

    group('Refresh input validation', () {
      test('Empty request body returns 400', () async {
        final response = await http.post(
          Uri.parse('${TestServerFactory.baseUrl}/auth/refresh'),
          body: '',
        );
        expect(response.statusCode, 400);
      });

      test('Missing refreshToken field returns 400', () async {
        final response = await http.post(
          Uri.parse('${TestServerFactory.baseUrl}/auth/refresh'),
          body: jsonEncode({}),
        );
        expect(response.statusCode, 400);
      });

      test('Empty refreshToken returns 400', () async {
        final response = await http.post(
          Uri.parse('${TestServerFactory.baseUrl}/auth/refresh'),
          body: jsonEncode({'refreshToken': ''}),
        );
        expect(response.statusCode, 400);
      });
    });
  });
}
