import 'dart:convert';
import 'package:shelf/shelf.dart';

import '../../../domain/value_objects/email.dart';
import '../../../domain/value_objects/password.dart';
import '../repositories/in_memory_user_repository.dart';
import '../security/token_service.dart';

class AuthService {
  AuthService(InMemoryUserRepository userRepository, TokenService tokenService)
      : _userRepository = userRepository,
        _tokenService = tokenService;

  final InMemoryUserRepository _userRepository;
  final TokenService _tokenService;

  Future<Response> handleLogin(Request req) async {
    try {
      final payload = await req.readAsString();
      if (payload.isEmpty) {
        return Response(400, body: jsonEncode({'error': 'Empty request body'}));
      }
      final data = jsonDecode(payload);
      final email = data['email'] as String?;
      final password = data['password'] as String?;

      if (email == null || password == null) {
        return Response(400,
            body: jsonEncode({'error': 'Missing email or password'}));
      }

      final user = _userRepository.getByEmail(email: Email(email));

      if (user == null) {
        return Response(401, body: jsonEncode({'error': 'Invalid email'}));
      }

      if (!_userRepository.isPasswordVerified(
          id: user.id, password: Password(password))) {
        return Response(401, body: jsonEncode({'error': 'Invalid password'}));
      }

      return Response.ok(jsonEncode({
        'accessToken': _tokenService.generateAccessToken(user),
        'refreshToken': _tokenService.generateRefreshToken(user)
      }));
    } catch (e) {
      return Response(500,
          body: jsonEncode(
              {'error': 'Internal server error', 'details': e.toString()}));
    }
  }

  Future<Response> handleRefreshAccessToken(Request req) async {
    try {
      final payload = await req.readAsString();
      if (payload.isEmpty) {
        return Response(400, body: jsonEncode({'error': 'Empty request body'}));
      }
      final data = jsonDecode(payload);
      final refreshToken = data['refreshToken'] as String?;

      if (refreshToken == null) {
        return Response(400,
            body: jsonEncode({'error': 'Missing refresh token'}));
      }

      final verifiedRefreshToken =
          _tokenService.verifyRefreshToken(refreshToken);

      final userId = _tokenService.extractUserId(verifiedRefreshToken);
      final user = _userRepository.get(id: userId);

      if (user == null) {
        return Response(401,
            body: jsonEncode({'error': 'Invalid refresh token'}));
      }

      return Response.ok(
          jsonEncode({'accessToken': _tokenService.generateAccessToken(user)}));
    } catch (e) {
      return Response(500,
          body: jsonEncode(
              {'error': 'Internal server error', 'details': e.toString()}));
    }
  }
}
