import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/user.dart';
import '../databases/refresh_token_database.dart';

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

  JWT verifyAccessToken(AccessToken token) => _verifyToken(token);

  RefreshToken generateRefreshToken(User user) {
    final jwt = JWT({'id': user.id.value});
    final token = _signToken(jwt, _refreshTokenExpiration);
    _refreshTokenDatabase.put(user.id, token);
    return token;
  }

  JWT verifyRefreshToken(User user, RefreshToken token) {
    final storedToken = _refreshTokenDatabase.get(user.id);
    if (storedToken == null || storedToken != token) {
      throw Exception('Invalid refresh token');
    }
    return _verifyToken(token);
  }

  void revokeRefreshToken(User user) => _refreshTokenDatabase.delete(user.id);

  String _signToken(JWT token, Duration expiration) =>
      token.sign(_key, expiresIn: expiration);

  JWT _verifyToken(String token) {
    try {
      return JWT.verify(token, _key);
    } catch (err) {
      throw err;
    }
  }
}
