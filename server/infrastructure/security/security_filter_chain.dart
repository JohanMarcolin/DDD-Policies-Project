import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf/shelf.dart';
import '../../../domain/entities/user.dart';
import 'token_service.dart';

extension CurrentUserRequestExtension on Request {
  User get currentUser {
    final user = context['currentUser'] as User?;
    if (user == null) {
      throw StateError('No authenticated user found in request context');
    }
    return user;
  }
}

class SecurityFilterChain {
  SecurityFilterChain({required TokenService tokenService})
      : _tokenService = tokenService;

  final TokenService _tokenService;

  static final _protectedPaths = {'user'};

  Middleware get middleware => (Handler protectedHandler) {
        return (Request req) async {
          final path = req.url.path;
          if (_isProtectedPath(path)) {
            try {
              req = _authorize(req);
            } catch (err) {
              return Response.forbidden(err.toString());
            }
          }

          return await protectedHandler(req);
        };
      };

  bool _isProtectedPath(String path) =>
      _protectedPaths.any((protected) => path.startsWith(protected));

  Request _authorize(Request req) {
    final verifiedAccessToken = _getVerifiedAccessToken(req);
    final currentUser = _extractCurrentUser(verifiedAccessToken);
    return _appendCurrentUser(req, currentUser);
  }

  JWT _getVerifiedAccessToken(Request req) {
    final accessToken = _extractAccessToken(req);

    final jwt = _tokenService.verifyAccessToken(accessToken);

    return jwt;
  }

  Request _appendCurrentUser(Request req, User user) {
    return req.change(context: {'currentUser': user});
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
