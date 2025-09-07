import 'package:shelf_router/shelf_router.dart';

import '../services/auth_service.dart';

class AuthRouteProvider {
  AuthRouteProvider(AuthService authService)
      : _authService = authService;

  final AuthService _authService;

  void appendRoutes(Router router) => router
    ..post('/auth/login', _authService.handleLogin)
    ..post('/auth/refresh', _authService.handleRefreshAccessToken);
}
