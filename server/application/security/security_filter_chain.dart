import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf/shelf.dart';
import '../../domain/entities/user.dart';
import '../../domain/value_objects/role.dart';
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
              final verifiedAccessToken = _getVerifiedAccessToken(req);
              final currentUser = _extractCurrentUser(verifiedAccessToken);
              _authorizePath(currentUser, path);
              _appendCurrentUser(req, currentUser);
            } catch (err) {
              return Response.forbidden(err.toString());
            }
          }

          return await protectedHandler(req);
        };
      };

  bool _isProtectedPath(String path) => _protectedPaths.contains(path);

  JWT _getVerifiedAccessToken(Request req) {
    final accessToken = _extractAccessToken(req);

    final jwt = _tokenService.verifyAccessToken(accessToken);

    if (jwt == null) {
      throw Exception('Invalid or expired access token');
    }

    return jwt;
  }

  void _authorizePath(User currentUser, String path) {
    if (path == 'admin' && currentUser.role != Role.admin) {
      throw Exception('Admin access required');
    }
  }

  void _appendCurrentUser(Request req, User user) {
    req.context['currentUser'] = user;
  }

  User _extractCurrentUser(JWT token) {
    return User(
        id: _tokenService.extractUserId(token),
        email: _tokenService.extractUserEmail(token),
        role: _tokenService.extractUserRole(token));
  }

  String _extractAccessToken(Request req) {
    final authHeader = req.headers['authorization'];

    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      throw Exception('Missing or malformed authorization header');
    }

    return authHeader.substring(7);
  }
}
