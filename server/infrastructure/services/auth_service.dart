import '../http/request_utils.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';

import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/password.dart';
import '../http/exceptions/request_exceptions.dart';
import '../http/response_utils.dart';
import '../mappers/user_mapper.dart';
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
    final data = await readJsonBody(req);
    final email = data['email'] as String?;

    if (email == null || email.isEmpty) {
      throw BadRequestException('Missing or empty email');
    }

    final password = data['password'] as String?;

    if (password == null || password.isEmpty) {
      throw BadRequestException('Missing or empty password');
    }

    final user = await _userRepository.getByEmail(email: Email(email));

    if (user == null) {
      throw NotFoundException('User not found');
    }

    if (!_userRepository.isPasswordVerified(
        userId: user.userId, password: Password(password))) {
      throw ForbiddenException('Invalid password');
    }

    return ok({
      'currentUser': UserMapper.toJson(user),
      'accessToken': _tokenService.generateAccessToken(user),
      'refreshToken': _tokenService.generateRefreshToken(user)
    });
  }

  Future<Response> handleRefreshAccessToken(Request req) async {
    final data = await readJsonBody(req);
    final refreshToken = data['refreshToken'] as String?;

    if (refreshToken == null || refreshToken.isEmpty) {
      throw BadRequestException('Missing or empty refresh token');
    }

    final verifiedRefreshToken = _tokenService.verifyRefreshToken(refreshToken);

    final userId = _tokenService.extractUserId(verifiedRefreshToken);
    final user = await _userRepository.get(userId: userId);

    if (user == null) {
      throw NotFoundException('User not found');
    }

    return ok({
      'currentUser': UserMapper.toJson(user),
      'accessToken': _tokenService.generateAccessToken(user)
    });
  }

  Future<Response> handleLogout(Request req) async {
    final refreshToken = req.params['refreshToken'];

    if (refreshToken == null || refreshToken.isEmpty) {
      throw BadRequestException('Missing or empty refresh token');
    }

    final verifiedRefreshToken = _tokenService.verifyRefreshToken(refreshToken);

    final userId = _tokenService.extractUserId(verifiedRefreshToken);
    final user = await _userRepository.get(userId: userId);

    if (user == null) {
      throw NotFoundException('User not found');
    }

    _tokenService.revokeRefreshToken(user);

    final revokedAccessToken = refreshToken;

    if (!_tokenService.isVerifiedAccessToken(revokedAccessToken)) {
      return deleted();
    }

    return badRequest('Could not revoke access token');
  }
}
