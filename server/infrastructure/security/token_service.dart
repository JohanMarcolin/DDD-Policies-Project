import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/user.dart';
import '../../../domain/value_objects/email.dart';
import '../../../domain/value_objects/id.dart';
import '../../../domain/value_objects/role.dart';
import '../databases/refresh_token_database.dart';
import '../http/exceptions/request_exceptions.dart';

typedef AccessToken = String;

class TokenService {
  TokenService({required RefreshTokenDatabase refreshTokenDatabase})
      : _refreshTokenDatabase = refreshTokenDatabase;

  final RefreshTokenDatabase _refreshTokenDatabase;

  static final SecretKey _key = SecretKey(Uuid().v4());
  final Duration _accessTokenExpiration = Duration(days: 1);
  final Duration _refreshTokenExpiration = Duration(days: 7);

  AccessToken generateAccessToken(User user) {
    final jwt = JWT({
      'id': user.id.value,
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
      throw InvalidAccessTokenException('Invalid access token');
    }
    return verifiedAccessToken;
  }

  RefreshToken generateRefreshToken(User user) {
    final jwt = JWT({'id': user.id.value});
    final token = _signToken(jwt, _refreshTokenExpiration);
    _refreshTokenDatabase.put(user.id, token);
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
      throw InvalidRefreshTokenException('Invalid or expired refresh token');
    }

    final tokenId = extractUserId(verifiedRefreshToken);

    final storedToken = _refreshTokenDatabase.get(tokenId);

    if (storedToken == null || storedToken != token) {
      throw InvalidRefreshTokenException('Could not find stored refresh token');
    }

    return verifiedRefreshToken;
  }

  void revokeRefreshToken(User user) => _refreshTokenDatabase.delete(user.id);

  String _signToken(JWT token, Duration expiration) =>
      token.sign(_key, expiresIn: expiration);

  JWT? _verifyToken(String token) => JWT.tryVerify(token, _key);

  Id extractUserId(JWT token) {
    final claims = _extractTokenClaims(token);
    final id = claims['id'];
    if (id == null) {
      throw InvalidUserClaimsException('Token does not contain a valid user id');
    }
    return Id(id);
  }

  Email extractUserEmail(JWT token) {
    final claims = _extractTokenClaims(token);
    final email = claims['username'];
    if (email == null) {
      throw InvalidUserClaimsException('Token does not contain a valid user email');
    }
    return Email(email);
  }

  Role extractUserRole(JWT token) {
    final claims = _extractTokenClaims(token);
    final role = claims['role'];
    if (role == null) {
      throw InvalidUserClaimsException('Token does not contain a valid user role');
    }
    switch (role) {
      case 'analyst':
        return Role.analyst;
      case 'admin':
        return Role.admin;
      case 'user':
        return Role.user;
      default:
        throw InvalidUserClaimsException('Unknown user role: $role');
    }
  }

  Map<String, dynamic> _extractTokenClaims(JWT token) => token.payload;
}
