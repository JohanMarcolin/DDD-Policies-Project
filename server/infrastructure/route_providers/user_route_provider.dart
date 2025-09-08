import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../../domain/policies/policy_violation_exception.dart';
import '../../../domain/services/user_administration/user_administration_service.dart';
import '../../../domain/value_objects/id.dart';
import '../mappers/user_mapper.dart';
import '../security/security_filter_chain.dart';

class UserRouteProvider {
  UserRouteProvider(
      {required UserAdministrationService userAdministrationService})
      : _userAdministrationService = userAdministrationService;

  final UserAdministrationService _userAdministrationService;

  void appendRoutes(Router router) => router
    ..get('/user/all', (Request req) {
      print('currentUser: ${req.currentUser.email.value}');
      try {
        final users =
            _userAdministrationService.getUsers(requester: req.currentUser);
        print(UserMapper.toJsonList(users));
        return Response.ok(jsonEncode(UserMapper.toJsonList(users)));
      } catch (e) {
        return Response.internalServerError();
      }
    })
    ..get('/user/<id>', (Request req) {
      final id = req.params['id'];

      if (id == null) return Response.forbidden('User ID is required');

      try {
        final user = _userAdministrationService.get(
            requester: req.currentUser, id: Id(id));

        if (user == null) return Response.notFound('User not found');

        return Response.ok(user);
      } on PolicyViolationException catch (e) {
        return Response.forbidden('Forbidden: ${e.reason}');
      } catch (e) {
        return Response.internalServerError(body: e.toString());
      }
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
