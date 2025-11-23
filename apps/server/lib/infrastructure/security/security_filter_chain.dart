import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:error_codes/error_codes.dart';
import 'package:shelf/shelf.dart';
import 'package:domain/entities/user.dart';
import '../http/exceptions/request_exceptions.dart';
import 'token_service.dart';

extension CurrentUserRequestExtension on Request {
  /// Returns the current authenticated [User] from the request context.
  ///
  /// Throws [AuthenticatedUserNotFoundException] if no user is present.
  User get currentUser {
    final user = context['currentUser'] as User?;
    if (user == null) {
      throw AuthenticatedUserNotFoundException(SecurityMissingAuthenticatedUser());
    }
    return user;
  }
}

/// Middleware for enforcing security and authorization on protected paths.
///
/// Validates access tokens, extracts user information, and attaches the authenticated user to the request context.
class SecurityFilterChain {
  SecurityFilterChain({required TokenService tokenService}) : _tokenService = tokenService;

  final TokenService _tokenService;

  static final _protectedPaths = {'user'};

  /// Returns a Shelf [Middleware] that enforces authorization on protected paths.
  ///
  /// Validates access tokens and appends the authenticated user to the request context.
  Middleware get middleware => (Handler protectedHandler) {
        return (Request req) async {
          final path = req.url.path;
          if (_isProtectedPath(path)) {
            try {
              req = _authorize(req);
            } catch (_) {
              rethrow;
            }
          }

          return await protectedHandler(req);
        };
      };

  /// Checks if the given [path] is protected and requires authorization.
  bool _isProtectedPath(String path) => _protectedPaths.any((protectedPath) => path.startsWith(protectedPath));

  /// Authorizes the [req] by verifying its access token and extracting the current user.
  ///
  /// Returns a new [Request] with the authenticated user attached to its context.
  /// Throws if authorization fails.
  Request _authorize(Request req) {
    final verifiedAccessToken = _getVerifiedAccessToken(req);
    final currentUser = _extractCurrentUser(verifiedAccessToken);
    return _appendCurrentUser(req, currentUser);
  }

  /// Extracts and verifies the access token from the [req].
  ///
  /// Returns a verified [JWT]. Throws if verification fails.
  JWT _getVerifiedAccessToken(Request req) {
    final accessToken = _extractAccessToken(req);

    final jwt = _tokenService.verifyAccessToken(accessToken);

    return jwt;
  }

  /// Appends the [user] to the [req] context as `currentUser`.
  Request _appendCurrentUser(Request req, User user) {
    return req.change(context: {'currentUser': user});
  }

  /// Extracts the [User] from the verified [JWT] token.
  User _extractCurrentUser(JWT token) {
    return User(
        userId: _tokenService.extractUserId(token),
        email: _tokenService.extractUserEmail(token),
        role: _tokenService.extractUserRole(token));
  }

  /// Extracts the access token string from the [req] authorization header.
  ///
  /// Throws [MissingAuthorizationHeaderException] if the header is missing.
  /// Throws [MalformedAuthorizationHeaderException] if the header is malformed.
  String _extractAccessToken(Request req) {
    final authHeader = req.headers['authorization'];

    if (authHeader == null) {
      throw MissingAuthorizationHeaderException(SecurityMissingAuthorizationHeader());
    }

    if (!authHeader.startsWith('Bearer ')) {
      throw MalformedAuthorizationHeaderException(SecurityMalformedAuthorizationHeader());
    }

    return authHeader.substring(7);
  }
}
