import 'package:shelf/shelf.dart';
import 'token_service.dart';

class SecurityFilterChain {
  SecurityFilterChain(TokenService tokenService) : _tokenService = tokenService;

  final TokenService _tokenService;

  static final _protectedPaths = {'user', 'admin', 'data'};

  Middleware get middleware => (Handler protectedHandler) {
        return (Request req) async {
          final path = req.url.path;

          if (_isProtectedPath(path)) {
            try {
              _authorize(req);
            } catch (err) {
              return Response.forbidden(err.toString());
            }
          }

          return await protectedHandler(req);
        };
      };

  bool _isProtectedPath(String path) => _protectedPaths.contains(path);

  void _authorize(Request req) {
    final token = extractToken(req);

    final jwt = _tokenService.verify(token);

    final path = req.url.path;

    if (path == 'admin' && jwt.payload['role'] != 'admin') {
      throw Exception('Admin access required');
    }
  }

  String extractToken(Request req) {
    final authHeader = req.headers['authorization'];

    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      throw Exception('Missing or malformed authorization header');
    }

    return authHeader.substring(7);
  }
}
