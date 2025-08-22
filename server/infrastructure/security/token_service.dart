import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../../domain/entities/user.dart';
typedef JwtToken = String;

class TokenService {
  TokenService(this._key);

  final SecretKey _key;
  final Duration _tokenExpiration = Duration(minutes: 5);

  JwtToken generate(User user) {
    final jwt = JWT({
      'id': user.id.value,
      'username': user.email.value,
      'role': user.role.name,
    });
    return jwt.sign(_key, expiresIn: _tokenExpiration);
  }

  JWT? verify(JwtToken token) {
    try {
      return JWT.verify(token, _key);
    } catch (_) {
      return null;
    }
  }
}
