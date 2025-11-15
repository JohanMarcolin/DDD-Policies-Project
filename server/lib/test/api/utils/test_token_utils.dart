import 'dart:convert';
import 'package:global_utils/test/test_server_fixture.dart';
import 'package:global_utils/test/user_test_fixture.dart';
import 'package:http/http.dart' as http;

Future<Map<String, String>> getAuthHeader(UserTestFixture userTestFixture) async {
  final accessToken = await _getAccessToken(userTestFixture: userTestFixture);
  return {
    'Authorization': 'Bearer $accessToken',
  };
}

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
