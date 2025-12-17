import 'dart:convert';
import 'package:api_error_codes/api_error_codes.dart';
import 'package:domain/value_objects/role.dart';
import 'package:test_utils/fixtures/user/user_test_fixture.dart';
import 'utils/api_test_server_fixture.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

void main() {
  late UserTestFixture user;

  setUpAll(() async => await ApiTestServerFixture.setup());

  tearDownAll(() async => await ApiTestServerFixture.teardown());

  group('Auth Controller', () {
    group('Shall succeed', () {
      for (final role in Role.values) {
        setUp(() async {
          user = await ApiTestServerFixture.createUserFixture(role: role);
        });

        test('Login returns tokens and current user for valid ${role.name} credentials', () async {
          final response = await http.post(
            Uri.parse('${ApiTestServerFixture.baseUrl}/auth/login'),
            body: jsonEncode({'email': user.email.value, 'password': user.password.value}),
          );

          expect(response.statusCode, 200);

          final body = jsonDecode(response.body);
          final accessToken = body['data']['accessToken'];
          final refreshToken = body['data']['refreshToken'];
          final currentUser = body['data']['currentUser'];

          expect(accessToken, isNotNull);
          expect(refreshToken, isNotNull);
          expect(currentUser['userId'], equals(user.userId.value));
        });

        test('Refresh returns new access token and current user for valid ${role.name} credentials', () async {
          final loginResponse = await http.post(
            Uri.parse('${ApiTestServerFixture.baseUrl}/auth/login'),
            body: jsonEncode({'email': user.email.value, 'password': user.password.value}),
          );

          final loginBody = jsonDecode(loginResponse.body);
          final refreshToken = loginBody['data']['refreshToken'];

          final refreshResponse = await http.post(
            Uri.parse('${ApiTestServerFixture.baseUrl}/auth/refresh'),
            body: jsonEncode({'refreshToken': refreshToken}),
          );

          expect(refreshResponse.statusCode, equals(200));

          final refreshBody = jsonDecode(refreshResponse.body);
          final newAccessToken = refreshBody['data']['accessToken'];
          final currentUser = refreshBody['data']['currentUser'];

          expect(newAccessToken, isNotNull);
          expect(currentUser['userId'], equals(user.userId.value));
        });

        test('Logout succeeds with valid refresh token', () async {
          final loginResponse = await http.post(
            Uri.parse('${ApiTestServerFixture.baseUrl}/auth/login'),
            body: jsonEncode({'email': user.email.value, 'password': user.password.value}),
          );
          final loginBody = jsonDecode(loginResponse.body);
          final refreshToken = loginBody['data']['refreshToken'];

          final logoutResponse = await http.delete(
            Uri.parse('${ApiTestServerFixture.baseUrl}/auth/logout/$refreshToken'),
          );
          expect(logoutResponse.statusCode, equals(204));
        });
      }
    });

    group('Shall fail', () {
      for (final role in Role.values) {
        final roleName = role.name;

        setUp(() async {
          user = await ApiTestServerFixture.createUserFixture(role: role);
        });

        test('Login fails for invalid $roleName credentials', () async {
          final response = await http.post(
            Uri.parse('${ApiTestServerFixture.baseUrl}/auth/login'),
            body: jsonEncode({'email': user.email.value, 'password': 'wrong'}),
          );
          expect(response.statusCode, equals(403));
        });
        test('Login fails for invalid credentials', () async {
          final user = await ApiTestServerFixture.createUserFixture(role: role);

          final response = await http.post(
            Uri.parse('${ApiTestServerFixture.baseUrl}/auth/login'),
            body: jsonEncode({'email': user.email.value, 'password': 'wrong'}),
          );
          expect(response.statusCode, equals(403));
          final body = jsonDecode(response.body);
          expect(body['apiErrorCode'], equals(LoginInvalidPassword().toString()));
        });

        test('Login fails for missing email', () async {
          final user = await ApiTestServerFixture.createUserFixture(role: role);

          final response = await http.post(
            Uri.parse('${ApiTestServerFixture.baseUrl}/auth/login'),
            body: jsonEncode({'password': user.password.value}),
          );
          expect(response.statusCode, equals(400));
          final body = jsonDecode(response.body);
          expect(body['apiErrorCode'], equals(LoginMissingEmail().toString()));
        });

        test('Login fails for missing password', () async {
          final user = await ApiTestServerFixture.createUserFixture(role: role);

          final response = await http.post(
            Uri.parse('${ApiTestServerFixture.baseUrl}/auth/login'),
            body: jsonEncode({'email': user.email.value}),
          );
          expect(response.statusCode, equals(400));
          final body = jsonDecode(response.body);
          expect(body['apiErrorCode'], equals(LoginMissingPassword().toString()));
        });

        test('Login fails for user not found', () async {
          final response = await http.post(
            Uri.parse('${ApiTestServerFixture.baseUrl}/auth/login'),
            body: jsonEncode({'email': 'notfound@example.com', 'password': 'irrelevant'}),
          );
          expect(response.statusCode, equals(404));
          final body = jsonDecode(response.body);
          expect(body['apiErrorCode'], equals(LoginUserNotFound().toString()));
        });

        test('Logout fails for invalid refresh token', () async {
          final response = await http.delete(
            Uri.parse('${ApiTestServerFixture.baseUrl}/auth/logout/invalidtoken'),
          );
          expect(response.statusCode, equals(401));
          final body = jsonDecode(response.body);
          expect(body['apiErrorCode'], equals(TokenInvalidRefreshToken().toString()));
        });
      }
    });

    group('Login input validation', () {
      test('Empty request body returns 400', () async {
        final response = await http.post(
          Uri.parse('${ApiTestServerFixture.baseUrl}/auth/login'),
          body: '',
        );
        expect(response.statusCode, 400);
        final body = jsonDecode(response.body);
        expect(body['apiErrorCode'], equals(PayloadMissingRequestBody().toString()));
      });

      test('Missing email returns 400', () async {
        for (final missingEmail in [null, '']) {
          final response = await http.post(
            Uri.parse('${ApiTestServerFixture.baseUrl}/auth/login'),
            body: jsonEncode({'password': 'irrelevant', 'email': missingEmail}),
          );
          expect(response.statusCode, 400);
          final body = jsonDecode(response.body);
          expect(body['apiErrorCode'], equals(LoginMissingEmail().toString()));
        }
      });

      test('Missing password returns 400', () async {
        for (final missingPassword in [null, '']) {
          final response = await http.post(
            Uri.parse('${ApiTestServerFixture.baseUrl}/auth/login'),
            body: jsonEncode({'email': 'some@example.com', 'password': missingPassword}),
          );
          expect(response.statusCode, 400);
          final body = jsonDecode(response.body);
          expect(body['apiErrorCode'], equals(LoginMissingPassword().toString()));
        }
      });
    });

    group('Refresh input validation', () {
      test('Empty request body returns 400', () async {
        final response = await http.post(
          Uri.parse('${ApiTestServerFixture.baseUrl}/auth/refresh'),
          body: '',
        );
        expect(response.statusCode, 400);
      });

      test('Missing refreshToken returns 400', () async {
        for (final missingRefreshToken in [null, '']) {
          final response = await http.post(
            Uri.parse('${ApiTestServerFixture.baseUrl}/auth/refresh'),
            body: jsonEncode({'refreshToken': missingRefreshToken}),
          );
          expect(response.statusCode, 400);
        }
      });
    });
  });
}
