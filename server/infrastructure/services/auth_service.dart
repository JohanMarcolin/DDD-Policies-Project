import 'dart:convert';
import 'package:shelf/shelf.dart';

import '../../../domain/value_objects/email.dart';
import '../../../domain/value_objects/password.dart';
import '../http/exceptions/request_exceptions.dart';
import '../http/response_utils.dart';
import '../repositories/in_memory_user_repository.dart';
import '../security/token_service.dart';

class AuthService {
  AuthService(
      {required InMemoryUserRepository userRepository,
      required TokenService tokenService})
      : _userRepository = userRepository,
        _tokenService = tokenService;

  final InMemoryUserRepository _userRepository;
  final TokenService _tokenService;

  Future<Response> handleLogin(Request req) async {
    final payload = await req.readAsString();
    if (payload.isEmpty) {
      throw BadRequestException('Empty request body');
    }

    final data = jsonDecode(payload);
    final email = data['email'] as String?;

    if (email == null || email.isEmpty) {
      throw BadRequestException('Missing or empty email');
    }

    final password = data['password'] as String?;

    if (password == null || password.isEmpty) {
      throw BadRequestException('Missing or empty password');
    }

    final user = _userRepository.getByEmail(email: Email(email));

    if (user == null) {
      throw NotFoundException('User not found');
    }

    if (!_userRepository.isPasswordVerified(
        id: user.id, password: Password(password))) {
      throw ForbiddenException('Invalid password');
    }

    return ok({
      'accessToken': _tokenService.generateAccessToken(user),
      'refreshToken': _tokenService.generateRefreshToken(user)
    });
  }

  Future<Response> handleRefreshAccessToken(Request req) async {
    final payload = await req.readAsString();
    if (payload.isEmpty) {
      throw BadRequestException('Empty request body');
    }
    final data = jsonDecode(payload);
    final refreshToken = data['refreshToken'] as String?;

    if (refreshToken == null || refreshToken.isEmpty) {
      throw BadRequestException('Missing or empty refresh token');
    }

    final verifiedRefreshToken = _tokenService.verifyRefreshToken(refreshToken);

    final userId = _tokenService.extractUserId(verifiedRefreshToken);
    final user = _userRepository.get(id: userId);

    if (user == null) {
      throw NotFoundException('User not found');
    }

    return ok({'accessToken': _tokenService.generateAccessToken(user)});
  }
}
