import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/user.dart';
typedef JwtToken = String;

class TokenService {
  TokenService();

  static final SecretKey _key = SecretKey(Uuid().v4());
  final Duration _tokenExpiration = Duration(minutes: 5);

  JwtToken generate(User user) {
    final jwt = JWT({
      'id': user.id.value,
      'username': user.email.value,
      'role': user.role.name,
    });
    return jwt.sign(_key, expiresIn: _tokenExpiration);
  }

  JWT verify(JwtToken token) {
    try {
      return JWT.verify(token, _key);
    } catch (err) {
      throw err;
    }
  }
}
