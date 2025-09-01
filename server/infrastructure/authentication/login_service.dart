import 'dart:convert';
import 'package:shelf/shelf.dart';

import '../../domain/value_objects/email.dart';
import '../repositories/in_memory_user_repository.dart';
import '../security/token_service.dart';

class LoginService {
  LoginService(InMemoryUserRepository repository, TokenService tokenService)
      : _repository = repository,
        _tokenService = tokenService;

  final InMemoryUserRepository _repository;
  final TokenService _tokenService;

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

      return Response.ok(jsonEncode({'token': _tokenService.generate(user)}),
          headers: {'content-type': 'application/json'});
    } catch (e) {
      return Response(500,
          body: jsonEncode(
              {'error': 'Internal server error', 'details': e.toString()}),
          headers: {'content-type': 'application/json'});
    }
  }
}
