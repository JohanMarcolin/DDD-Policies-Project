import 'dart:convert';
import 'package:test_utils/fixtures/server/test_server_fixture.dart';
import 'package:test_utils/fixtures/user/user_test_fixture.dart';
import 'package:http/http.dart' as http;

/// Generates an HTTP Authorization header for the given [UserTestFixture].
///
/// Performs a login request and extracts the access token for use in authenticated test requests.
Future<Map<String, String>> getAuthHeader(UserTestFixture userTestFixture) async {
  final accessToken = await _getAccessToken(userTestFixture: userTestFixture);
  return {
    'Authorization': 'Bearer $accessToken',
  };
}

/// Performs a login request for the given [UserTestFixture] and returns the access token.
///
/// Used internally by [getAuthHeader] to support authenticated test scenarios.
Future<String> _getAccessToken({required UserTestFixture userTestFixture}) async {
  final response = await http.post(
    Uri.parse('${TestServerFixture.baseUrl}/auth/login'),
    body: jsonEncode({
      'email': userTestFixture.email.value,
      'password': userTestFixture.password.value,
    }),
  );
  final data = jsonDecode(response.body);
  return data['data']['accessToken'] as String;
}
