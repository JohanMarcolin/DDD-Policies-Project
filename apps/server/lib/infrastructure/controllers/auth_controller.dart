import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../services/auth_service.dart';

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
