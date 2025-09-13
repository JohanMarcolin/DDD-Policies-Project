import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../test_data_factories/test_user_entry_factory.dart';
import '../../test_data_factories/test_server_factory.dart';

Future<String> getAccessToken({required TestUserEntry testUserEntry}) async {
  final response = await http.post(
    Uri.parse('${TestServerFactory.baseUrl}/auth/login'),
    body: jsonEncode({
      'email': testUserEntry.email.value,
      'password': testUserEntry.password.value,
    }),
  );
  final data = jsonDecode(response.body);
  return data['result']['accessToken'] as String;
}

Map<String, String> getAuthHeader(String accessToken) => {
      'Authorization': 'Bearer $accessToken',
    };
