import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../services/auth_service.dart';

class AuthController {
  AuthController({required AuthService authService})
      : _authService = authService,
        _authRouter = Router() {
    _authRouter.post('/login', _handleLogin);
    _authRouter.post('/refresh', _handleRefresh);
  }

  final AuthService _authService;
  final Router _authRouter;

  Handler get handler => _authRouter;

  Future<Response> _handleLogin(Request request) {
    return _authService.handleLogin(request);
  }

  Future<Response> _handleRefresh(Request request) {
    return _authService.handleRefreshAccessToken(request);
  }
}
