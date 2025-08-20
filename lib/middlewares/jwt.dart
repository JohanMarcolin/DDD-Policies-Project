import 'package:shelf/shelf.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

Middleware jwtMiddleware = (Handler innerHandler) {
  return (Request request) async {
    final protectedPaths = ['user', 'admin', 'data'];
    final path = request.url.path;
    if (protectedPaths.contains(path)) {
      final authHeader = request.headers['authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.forbidden('Missing or invalid Authorization header');
      }
      final token = authHeader.substring(7);
      try {
        final jwt = JWT.verify(token, SecretKey('my-secret-key'));
        if (path == 'admin' && jwt.payload['role'] != 'admin') {
          return Response.forbidden('Admin access required');
        }
      } catch (e) {
        return Response.forbidden('Invalid or expired token: $e');
      }
    }
    return await innerHandler(request);
  };
};
