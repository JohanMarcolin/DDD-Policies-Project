import 'dart:convert';
import 'package:client/infrastructure/apis/api.dart';
import 'package:client/infrastructure/mappers/user_mapper.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/password.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthApi implements Api {
  AuthApi();

  final String baseUrl = Api.baseUrl;

  Future<bool> get hasAccessToken async => (await accessToken) != null;

  Future<String?> get accessToken async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  Future<void> setAccessToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token == null) {
      await prefs.remove('accessToken');
    } else {
      await prefs.setString('accessToken', token);
    }
  }

  Future<bool> get hasRefreshToken async => (await refreshToken) != null;

  Future<String?> get refreshToken async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refreshToken');
  }

  Future<void> setRefreshToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token == null) {
      await prefs.remove('refreshToken');
    } else {
      await prefs.setString('refreshToken', token);
    }
  }

  Future<User> login({required Email email, required Password password}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.value, 'password': password.value}),
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final currentUser = decoded['result']['currentUser'];
      final accessToken = decoded['result']['accessToken'];
      final refreshToken = decoded['result']['refreshToken'];
      await setAccessToken(accessToken);
      await setRefreshToken(refreshToken);
      return UserMapper.toDomainUser(currentUser);
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
  }

  Future<User> refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');
    if (refreshToken == null) {
      throw Exception('No refresh token found');
    }
    final response = await http.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final currentUser = decoded['result']['currentUser'];
      final newAccessToken = decoded['result']['accessToken'];
      await setAccessToken(newAccessToken);
      return UserMapper.toDomainUser(currentUser);
    } else {
      throw Exception('Failed to refresh access token: ${response.body}');
    }
  }
}
