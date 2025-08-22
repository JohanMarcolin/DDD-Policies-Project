import 'package:shelf/shelf.dart';
import 'token_service.dart';

class SecurityFilterChain {
  SecurityFilterChain(TokenService tokenService) : _tokenService = tokenService;

  final TokenService _tokenService;

  static final _protectedPaths = {'user', 'admin', 'data'};

  Middleware get middleware => (Handler innerHandler) {
        return (Request request) async {
          final path = request.url.path;

          if (_isProtectedPath(path)) _authorize(request);

          return await innerHandler(request);
        };
      };

  bool _isProtectedPath(String path) => _protectedPaths.contains(path);

  Response? _authorize(Request request) {
    final authHeader = request.headers['authorization'];

    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return Response.forbidden('Missing or malformed authorization header');
    }

    final token = authHeader.substring(7);
    try {
      final jwt = _tokenService.verify(token);

      if (jwt == null) {
        return Response.forbidden('Invalid or expired token');
      }

      final path = request.url.path;

      if (path == 'admin' && jwt.payload['role'] != 'admin') {
        return Response.forbidden('Admin access required');
      }
    } catch (e) {
      return Response.forbidden('Invalid token: $e');
    }

    return null;
  }
}
