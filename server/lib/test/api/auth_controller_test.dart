import 'dart:convert';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

import '../utils/factories/test_server_factory.dart';
import '../utils/factories/test_user_entry_factory.dart';

void main() {
  final testEntries = UserTestFixtureFactory.defaultUserTestFixtures;

  setUpAll(() async {
    await TestServerFactory.start(includeDefaultUsers: true);
  });

  tearDownAll(() async {
    await TestServerFactory.stop();
  });

  group('Auth Controller', () {
    group('Shall succeed', () {
      for (final testEntry in testEntries) {
        test(
            'Login returns tokens and current user for valid {$testEntry} credentials',
            () async {
          final response = await http.post(
            Uri.parse('${TestServerFactory.baseUrl}/auth/login'),
            body: jsonEncode({
              'email': testEntry.email.value,
              'password': testEntry.password.value
            }),
          );

          expect(response.statusCode, 200);

          final body = jsonDecode(response.body);
          final accessToken = body['data']['accessToken'];
          final refreshToken = body['data']['refreshToken'];
          final currentUser = body['data']['currentUser'];

          expect(accessToken, isNotNull);
          expect(refreshToken, isNotNull);
          expect(currentUser['userId'], equals(testEntry.user.userId.value));
        });
      }

      for (final testEntry in testEntries) {
        test(
            'Refresh returns new access token and current user for valid {$testEntry} credentials',
            () async {
          final loginResponse = await http.post(
            Uri.parse('${TestServerFactory.baseUrl}/auth/login'),
            body: jsonEncode({
              'email': testEntry.email.value,
              'password': testEntry.password.value
            }),
          );

          final loginBody = jsonDecode(loginResponse.body);
          final refreshToken = loginBody['data']['refreshToken'];

          final refreshResponse = await http.post(
            Uri.parse('${TestServerFactory.baseUrl}/auth/refresh'),
            body: jsonEncode({'refreshToken': refreshToken}),
          );

          expect(refreshResponse.statusCode, equals(200));

          final refreshBody = jsonDecode(refreshResponse.body);
          final newAccessToken = refreshBody['data']['accessToken'];
          final currentUser = refreshBody['data']['currentUser'];

          expect(newAccessToken, isNotNull);
          expect(currentUser['userId'], equals(testEntry.user.userId.value));
        });
      }
      for (final testEntry in testEntries) {
        test('Logout succeeds with valid refresh token', () async {
          final loginResponse = await http.post(
            Uri.parse('${TestServerFactory.baseUrl}/auth/login'),
            body: jsonEncode({
              'email': testEntry.email.value,
              'password': testEntry.password.value
            }),
          );
          final loginBody = jsonDecode(loginResponse.body);
          final refreshToken = loginBody['data']['refreshToken'];

          final logoutResponse = await http.delete(
            Uri.parse('${TestServerFactory.baseUrl}/auth/logout/$refreshToken'),
          );
          expect(logoutResponse.statusCode, equals(204));
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
      test('Login fails for invalid credentials', () async {
        final response = await http.post(
          Uri.parse('${TestServerFactory.baseUrl}/auth/login'),
          body: jsonEncode(
              {'email': testEntries.first.email.value, 'password': 'wrong'}),
        );
        expect(response.statusCode, equals(403));
        final body = jsonDecode(response.body);
        expect(body['errorCode'], equals('LoginInvalidPassword'));
      });

      test('Login fails for missing email', () async {
        final response = await http.post(
          Uri.parse('${TestServerFactory.baseUrl}/auth/login'),
          body: jsonEncode({'password': testEntries.first.password.value}),
        );
        expect(response.statusCode, equals(400));
        final body = jsonDecode(response.body);
        expect(body['errorCode'], equals('LoginMissingEmail'));
      });

      test('Login fails for missing password', () async {
        final response = await http.post(
          Uri.parse('${TestServerFactory.baseUrl}/auth/login'),
          body: jsonEncode({'email': testEntries.first.email.value}),
        );
        expect(response.statusCode, equals(400));
        final body = jsonDecode(response.body);
        expect(body['errorCode'], equals('LoginMissingPassword'));
      });

      test('Login fails for user not found', () async {
        final response = await http.post(
          Uri.parse('${TestServerFactory.baseUrl}/auth/login'),
          body: jsonEncode(
              {'email': 'notfound@example.com', 'password': 'irrelevant'}),
        );
        expect(response.statusCode, equals(404));
        final body = jsonDecode(response.body);
        expect(body['errorCode'], equals('LoginUserNotFound'));
      });

      test('Logout fails for invalid refresh token', () async {
        final response = await http.delete(
          Uri.parse('${TestServerFactory.baseUrl}/auth/logout/invalidtoken'),
        );
        expect(response.statusCode, equals(401));
        final body = jsonDecode(response.body);
        expect(body['errorCode'], equals('TokenInvalidRefreshToken'));
      });
    });

    group('Login input validation', () {
      test('Empty request body returns 400', () async {
        final response = await http.post(
          Uri.parse('${TestServerFactory.baseUrl}/auth/login'),
          body: '',
        );
        expect(response.statusCode, 400);
        final body = jsonDecode(response.body);
        expect(body['errorCode'], equals('PayloadMissingRequestBody'));
      });

      test('Missing email returns 400', () async {
        for (final missingEmail in [null, '']) {
          final response = await http.post(
            Uri.parse('${TestServerFactory.baseUrl}/auth/login'),
            body: jsonEncode({
              'password': testEntries.first.password.value,
              'email': missingEmail
            }),
          );
          expect(response.statusCode, 400);
          final body = jsonDecode(response.body);
          expect(body['errorCode'], equals('LoginMissingEmail'));
        }
      });

      test('Missing password returns 400', () async {
        for (final missingPassword in [null, '']) {
          final response = await http.post(
            Uri.parse('${TestServerFactory.baseUrl}/auth/login'),
            body: jsonEncode({
              'email': testEntries.first.email.value,
              'password': missingPassword
            }),
          );
          expect(response.statusCode, 400);
          final body = jsonDecode(response.body);
          expect(body['errorCode'], equals('LoginMissingPassword'));
        }
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

      test('Missing refreshToken returns 400', () async {
        for (final missingRefreshToken in [null, '']) {
          final response = await http.post(
            Uri.parse('${TestServerFactory.baseUrl}/auth/refresh'),
            body: jsonEncode({'refreshToken': missingRefreshToken}),
          );
          expect(response.statusCode, 400);
        }
      });
    });
  });
}
