import 'dart:convert';
import 'package:client/infrastructure/apis/api.dart';
import 'package:client/infrastructure/mappers/user_mapper.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/password.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserApi implements Api {
  UserApi();

  final String baseUrl = Api.baseUrl;

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<List<User>> get users async {
    final accessToken = await _getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/user/all'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> userList =
          decoded is Map && decoded.containsKey('result')
          ? decoded['result']
          : decoded;
      return UserMapper.toDomainUserList(userList.cast<Map<String, dynamic>>());
    } else {
      throw Exception('Failed to load users: ${response.body}');
    }
  }

  Future<User?> get({required UserId userId}) async {
    final accessToken = await _getAccessToken();
    final response = await http.get(
      Uri.parse('$baseUrl/user/${userId.value}'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final userJson = decoded is Map && decoded.containsKey('result')
          ? decoded['result']
          : decoded;
      return UserMapper.toDomainUser(userJson);
    } else {
      throw Exception('Failed to get user: ${response.body}');
    }
  }

  Future<void> delete({required UserId userId}) async {
    final accessToken = await _getAccessToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/user/${userId.value}'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to remove user: ${response.body}');
    }
  }

  Future<void> updateEmail({
    required UserId userId,
    required Email newEmail,
  }) async {
    final accessToken = await _getAccessToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/user/${userId.value}/email'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': newEmail.value}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update email: ${response.body}');
    }
  }

  Future<void> updatePassword({
    required UserId userId,
    required Password newPassword,
  }) async {
    final accessToken = await _getAccessToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/user/${userId.value}/password'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'password': newPassword.value}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update password: ${response.body}');
    }
  }
}
