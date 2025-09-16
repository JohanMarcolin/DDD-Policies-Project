import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/user.dart';

class UserRepository {
  // Use 10.0.2.2 for Android emulator, 127.0.0.1 for iOS simulator, or your computer's IP for real device
  static const String baseUrl = 'http://10.0.2.2:8080';

  Future<List<User>> listUsers(String accessToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => User.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> removeUser(String accessToken, String userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to remove user');
    }
  }

  Future<void> updateEmail(
    String accessToken,
    String userId,
    String newEmail,
  ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/users/$userId/email'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': newEmail}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update email');
    }
  }

  Future<void> updatePassword(
    String accessToken,
    String userId,
    String newPassword,
  ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/users/$userId/password'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'password': newPassword}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update password');
    }
  }
}
