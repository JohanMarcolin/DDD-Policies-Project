import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:global_utils/error_codes.dart';
import 'package:uuid/uuid.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/role.dart';
import '../databases/refresh_token_database.dart';
import '../http/exceptions/request_exceptions.dart';

typedef AccessToken = String;

class TokenService {
  TokenService({required RefreshTokenDatabase refreshTokenDatabase}) : _refreshTokenDatabase = refreshTokenDatabase;

  final RefreshTokenDatabase _refreshTokenDatabase;

  static final SecretKey _key = SecretKey(Uuid().v4());
  final Duration _accessTokenExpiration = Duration(minutes: 5);
  final Duration _refreshTokenExpiration = Duration(days: 7);

  AccessToken generateAccessToken(User user) {
    final jwt = JWT({
      'id': user.userId.value,
      'username': user.email.value,
      'role': user.role.name,
    });
    return _signToken(jwt, _accessTokenExpiration);
  }

  bool isVerifiedAccessToken(AccessToken token) {
    try {
      verifyAccessToken(token);
      return true;
    } catch (_) {
      return false;
    }
  }

  JWT verifyAccessToken(AccessToken token) {
    final verifiedAccessToken = _verifyToken(token);
    if (verifiedAccessToken == null) {
      throw InvalidAccessTokenException(TokenInvalidAccessToken());
    }
    return verifiedAccessToken;
  }

  RefreshToken generateRefreshToken(User user) {
    final jwt = JWT({'id': user.userId.value});
    final token = _signToken(jwt, _refreshTokenExpiration);
    _refreshTokenDatabase.put(user.userId, token);
    return token;
  }

  bool isVerifiedRefreshToken(RefreshToken token) {
    try {
      verifyRefreshToken(token);
      return true;
    } catch (_) {
      return false;
    }
  }

  JWT verifyRefreshToken(RefreshToken token) {
    final verifiedRefreshToken = _verifyToken(token);

    if (verifiedRefreshToken == null) {
      throw InvalidRefreshTokenException(TokenInvalidRefreshToken());
    }

    final tokenId = extractUserId(verifiedRefreshToken);

    final storedToken = _refreshTokenDatabase.get(tokenId);

    if (storedToken == null || storedToken != token) {
      throw InvalidRefreshTokenException(TokenInvalidRefreshToken());
    }

    return verifiedRefreshToken;
  }

  void revokeRefreshToken(User user) => _refreshTokenDatabase.delete(user.userId);

  String _signToken(JWT token, Duration expiration) => token.sign(_key, expiresIn: expiration);

  JWT? _verifyToken(String token) => JWT.tryVerify(token, _key);

  UserId extractUserId(JWT token) {
    final claims = _extractTokenClaims(token);
    final id = claims['id'];
    if (id == null) {
      throw InvalidUserClaimsException(TokenInvalidUserIdInToken());
    }
    return UserId(id);
  }

  Email extractUserEmail(JWT token) {
    final claims = _extractTokenClaims(token);
    final email = claims['username'];
    if (email == null) {
      throw InvalidUserClaimsException(TokenInvalidUserEmailInToken());
    }
    return Email(email);
  }

  Role extractUserRole(JWT token) {
    final claims = _extractTokenClaims(token);
    final role = claims['role'];

    switch (role) {
      case 'analyst':
        return Role.analyst;
      case 'admin':
        return Role.admin;
      case 'user':
        return Role.user;
      default:
        throw InvalidUserClaimsException(TokenInvalidUserRoleInToken());
    }
  }

  Map<String, dynamic> _extractTokenClaims(JWT token) => token.payload;
}
