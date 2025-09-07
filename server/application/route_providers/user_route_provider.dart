import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../../domain/services/user_administration/user_administration_service.dart';

class UserRouteProvider {
  UserRouteProvider(UserAdministrationService userAdministrationService)
      : _userAdministrationService = userAdministrationService;

  final UserAdministrationService _userAdministrationService;

  void appendRoutes(Router router) => router
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
