import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../../domain/value_objects/email.dart';
import '../repositories/in_memory_user_repository.dart';

class LoginService {
  LoginService(InMemoryUserRepository repository) : _repository = repository;

  final InMemoryUserRepository _repository;

  Future<Response> handler(Request req) async {
    try {
      final payload = await req.readAsString();
      if (payload.isEmpty) {
        return Response(400,
            body: jsonEncode({'error': 'Empty request body'}),
            headers: {'content-type': 'application/json'});
      }
      final data = jsonDecode(payload);
      final email = data['email'] as String?;
      final password = data['password'] as String?;

      if (email == null || password == null) {
        return Response(400,
            body: jsonEncode({'error': 'Missing email or password'}),
            headers: {'content-type': 'application/json'});
      }

      final user = _repository.getByEmail(Email(email));

      if (user == null || user.password.value != password) {
        return Response(401,
            body: jsonEncode({'error': 'Invalid credentials'}),
            headers: {'content-type': 'application/json'});
      }

      final jwt = JWT({
        'id': user.id.value,
        'username': user.email.value,
        'role': user.role.name,
      });
      final token =
          jwt.sign(SecretKey('my-secret-key'), expiresIn: Duration(hours: 1));
      return Response.ok(jsonEncode({'token': token}),
          headers: {'content-type': 'application/json'});
    } catch (e) {
      return Response(500,
          body: jsonEncode(
              {'error': 'Internal server error', 'details': e.toString()}),
          headers: {'content-type': 'application/json'});
    }
  }
}
