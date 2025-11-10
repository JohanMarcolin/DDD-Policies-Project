import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/factories/test_user_entry_factory.dart';
import '../../utils/factories/test_server_factory.dart';

Future<String> getAccessToken({required UserEntry userEntry}) async {
  final response = await http.post(
    Uri.parse('${TestServerFactory.baseUrl}/auth/login'),
    body: jsonEncode({
      'email': userEntry.email.value,
      'password': userEntry.password.value,
    }),
  );
  final data = jsonDecode(response.body);
  return data['data']['accessToken'] as String;
}

Map<String, String> getAuthHeader(String accessToken) => {
      'Authorization': 'Bearer $accessToken',
    };
