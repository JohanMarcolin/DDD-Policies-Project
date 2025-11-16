import 'package:domain/repositories/user_repository.dart';
import 'package:domain/value_objects/id.dart';
import 'package:global_utils/error_codes.dart';
import 'package:global_utils/mappers/user_mapper.dart';
import 'package:server/infrastructure/databases/user_password_database.dart';

import '../http/request_utils.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';

import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/password.dart';
import '../http/exceptions/request_exceptions.dart';
import '../http/response_utils.dart';
import '../security/token_service.dart';

class AuthService {
  AuthService(
      {required UserRepository userRepository,
      required UserPasswordDatabase userPasswordDatabase,
      required TokenService tokenService})
      : _userRepository = userRepository,
        _userPasswordDatabase = userPasswordDatabase,
        _tokenService = tokenService;

  final UserRepository _userRepository;
  final UserPasswordDatabase _userPasswordDatabase;
  final TokenService _tokenService;

  Future<Response> handleLogin(Request req) async {
    final data = await readJsonBody(req);
    final email = data['email'] as String?;

    if (email == null || email.isEmpty) {
      throw BadRequestException(LoginMissingEmail());
    }

    final password = data['password'] as String?;

    if (password == null || password.isEmpty) {
      throw BadRequestException(LoginMissingPassword());
    }

    final user = await _userRepository.getByEmail(email: Email(email));

    if (user == null) {
      throw NotFoundException(LoginUserNotFound());
    }

    final isUserPasswordVerified = await _isPasswordVerified(userId: user.userId, password: Password(password));

    if (!isUserPasswordVerified) {
      throw ForbiddenException(LoginInvalidPassword());
    }

    final currentUser = UserMapper.toJson(user);
    final accessToken = _tokenService.generateAccessToken(user);
    final refreshToken = await _tokenService.generateRefreshToken(user);

    return ok({'currentUser': currentUser, 'accessToken': accessToken, 'refreshToken': refreshToken});
  }

  Future<bool> _isPasswordVerified({required UserId userId, required Password password}) async {
    try {
      return await _userPasswordDatabase.isPasswordVerified(userId, password);
    } catch (e) {
      throw ServerErrorException(UserRepoCouldNotVerifyPassword());
    }
  }

  Future<Response> handleRefreshAccessToken(Request req) async {
    final data = await readJsonBody(req);
    final refreshToken = data['refreshToken'] as String?;

    if (refreshToken == null || refreshToken.isEmpty) {
      throw BadRequestException(RefreshMissingRefreshToken());
    }

    final verifiedRefreshToken = await _tokenService.verifyRefreshToken(refreshToken);

    final userId = _tokenService.extractUserId(verifiedRefreshToken);
    final user = await _userRepository.get(userId: userId);

    if (user == null) {
      throw NotFoundException(RefreshUserNotFound());
    }

    return ok({'currentUser': UserMapper.toJson(user), 'accessToken': _tokenService.generateAccessToken(user)});
  }

  Future<Response> handleLogout(Request req) async {
    final refreshToken = req.params['refreshToken'];

    if (refreshToken == null || refreshToken.isEmpty) {
      throw BadRequestException(LogoutMissingRefreshToken());
    }

    final verifiedRefreshToken = await _tokenService.verifyRefreshToken(refreshToken);

    final userId = _tokenService.extractUserId(verifiedRefreshToken);
    final user = await _userRepository.get(userId: userId);

    if (user == null) {
      throw NotFoundException(LogoutMissingUser());
    }

    await _tokenService.revokeRefreshToken(user);

    final revokedRefreshToken = refreshToken;

    final isVerifiedRefreshToken = await _tokenService.isVerifiedRefreshToken(revokedRefreshToken);

    if (!isVerifiedRefreshToken) {
      return deleted();
    }

    throw ServerErrorException(LogoutCouldNotRevokeRefreshToken());
  }
}
