import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

Future<Response> loginHandler(Request req) async {
  final payload = await req.readAsString();
  try {
    final data = payload.isNotEmpty ? jsonDecode(payload) : {};
    final username = data['username'] ?? 'guest';
    final role = data['role'] ?? 'user';
    final jwt = JWT({
      'username': username,
      'role': role,
    });
    final token =
        jwt.sign(SecretKey('my-secret-key'), expiresIn: Duration(hours: 1));
    return Response.ok(jsonEncode({'token': token}),
        headers: {'content-type': 'application/json'});
  } catch (e) {
    return Response.internalServerError(body: 'Invalid login payload: $e');
  }
}
