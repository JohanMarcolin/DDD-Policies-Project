import 'dart:math';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/user.dart';
import '../../domain/value_objects/email.dart';
import '../../domain/value_objects/id.dart';
import '../../domain/value_objects/role.dart';
import '../../infrastructure/databases/refresh_token_database.dart';

typedef AccessToken = String;

class TokenService {
  TokenService(RefreshTokenDatabase refreshTokenDatabase)
      : _refreshTokenDatabase = refreshTokenDatabase;

  final RefreshTokenDatabase _refreshTokenDatabase;

  static final SecretKey _key = SecretKey(Uuid().v4());
  final Duration _accessTokenExpiration = Duration(minutes: 5);
  final Duration _refreshTokenExpiration = Duration(days: 7);

  AccessToken generateAccessToken(User user) {
    final jwt = JWT({
      'id': user.id.value,
      'username': user.email.value,
      'role': user.role.name,
    });
    return _signToken(jwt, _accessTokenExpiration);
  }

  JWT verifyAccessToken(AccessToken token) {
    final verifiedAccessToken = _verifyToken(token);
    if (verifiedAccessToken == null) {
      throw Exception('Invalid or expired access token');
    }
    return verifiedAccessToken;
  }

  RefreshToken generateRefreshToken(User user) {
    final jwt = JWT({'id': user.id.value});
    final token = _signToken(jwt, _refreshTokenExpiration);
    _refreshTokenDatabase.put(user.id, token);
    return token;
  }

  JWT verifyRefreshToken(RefreshToken token) {
    final verifiedRefreshToken = _verifyToken(token);

    if (verifiedRefreshToken == null) {
      throw Exception('Invalid or expired refresh token');
    }

    final tokenId = extractUserId(verifiedRefreshToken);

    final storedToken = _refreshTokenDatabase.get(tokenId);

    if (storedToken == null || storedToken != token) {
      throw Exception('Invalid refresh token');
    }

    return verifiedRefreshToken;
  }

  RefreshToken rotateRefreshToken(User user) {
    final oldToken = _refreshTokenDatabase.get(user.id);
    if (oldToken != null) {
      _refreshTokenDatabase.delete(user.id);
      return generateRefreshToken(user);
    }
    throw Exception('No existing refresh token');
  }

  void revokeRefreshToken(User user) => _refreshTokenDatabase.delete(user.id);

  String _signToken(JWT token, Duration expiration) =>
      token.sign(_key, expiresIn: expiration);

  JWT? _verifyToken(String token) => JWT.tryVerify(token, _key);

  Id extractUserId(JWT token) {
    final claims = _extractTokenClaims(token);
    return Id(claims['id']);
  }

  Email extractUserEmail(JWT token) {
    final claims = _extractTokenClaims(token);
    return Email(claims['username']);
  }

  Role extractUserRole(JWT token) {
    final claims = _extractTokenClaims(token);
    switch (claims['role']) {
      case 'analyst':
        return Role.analyst;
      case 'admin':
        return Role.admin;
      default:
        return Role.user;
    }
  }

  Map<String, dynamic> _extractTokenClaims(JWT token) => token.payload;
}
