import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../services/auth_service.dart';

/// Controller for authentication endpoints.
///
/// Provides routes for user authentication:
/// - `POST /login`: Authenticates a user and returns tokens and user info.
/// - `POST /refresh`: Exchanges a refresh token for a new access token.
/// - `DELETE /logout/<refreshToken>`: Invalidates a refresh token and logs out the user.
class AuthController {
  AuthController({required AuthService authService})
      : _authService = authService,
        _authRouter = Router() {
    _authRouter.post('/login', _handleLogin);
    _authRouter.post('/refresh', _handleRefresh);
    _authRouter.delete('/logout/<refreshToken>', _handleLogout);
  }

  final AuthService _authService;
  final Router _authRouter;

  Handler get handler => _authRouter.call;

  Future<Response> _handleLogin(Request request) async {
    return await _authService.handleLogin(request);
  }

  Future<Response> _handleRefresh(Request request) async {
    return await _authService.handleRefreshAccessToken(request);
  }

  Future<Response> _handleLogout(Request request) async {
    return await _authService.handleLogout(request);
  }
}
