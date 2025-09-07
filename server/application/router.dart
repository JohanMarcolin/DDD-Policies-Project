import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'authentication/auth_service.dart';

class RouterProvider {
  RouterProvider(AuthService authService) : _authService = authService;

  final AuthService _authService;

  Router get handler => Router()
    ..post('/auth/login', _authService.handleLogin)
    ..post('/auth/refresh', _authService.handleRefresh)
    ..get('/user/<id>', (Request req) {
      final id = req.params['id'];
      return Response.ok('User: $id');
    })
    ..delete('/user/<id>', (Request req) {
      final id = req.params['id'];
      return Response.ok('Deleted user: $id');
    })
    ..post('/user/email', (Request req) {
      return req.readAsString().then((body) {
        final newEmail = body;
        return Response.ok('Received new email: $newEmail');
      });
    })
    ..post('/user/password', (Request req) {
      return req.readAsString().then((body) {
        final newPassword = body;
        return Response.ok('Received new password: $newPassword');
      });
    });
}
