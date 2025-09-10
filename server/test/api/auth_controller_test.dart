import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

import 'factories/test_server_factory.dart';
import 'factories/test_user_factory.dart';

void main() {
  setUpAll(() async {
    await TestServerFactory.start();
  });

  tearDownAll(() async {
    await TestServerFactory.stop();
  });

  group('Auth Controller', () {
    group('Shall succeed', () {
      for (final testEntry in TestUserFactory.defaultUserEntries) {
        test('Login returns tokens for valid ${testEntry} credentials',
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

        test('Refresh returns new access token', () async {
          final loginResponse = await http.post(
            Uri.parse('${TestServerFactory.baseUrl}/auth/login'),
            body: jsonEncode({'email': 'analyst', 'password': 'analyst'}),
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
          body: jsonEncode({'email': 'analyst', 'password': 'wrong'}),
        );
        expect(response.statusCode, equals(403));
      });
    });
  });
}
