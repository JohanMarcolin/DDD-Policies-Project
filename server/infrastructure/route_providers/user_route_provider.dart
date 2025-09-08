import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../../domain/policies/policy_violation_exception.dart';
import '../../../domain/services/user_administration/user_administration_service.dart';
import '../../../domain/value_objects/email.dart';
import '../../../domain/value_objects/id.dart';
import '../../../domain/value_objects/password.dart';
import '../http/json_response_entity.dart';
import '../mappers/user_mapper.dart';
import '../security/security_filter_chain.dart';

class UserRouteProvider {
  UserRouteProvider(
      {required UserAdministrationService userAdministrationService})
      : _userAdministrationService = userAdministrationService;

  final UserAdministrationService _userAdministrationService;

  void appendRoutes(Router router) => router
    ..get('/user/all', (Request req) {
      try {
        final users = UserMapper.toJsonList(
            _userAdministrationService.getUsers(requester: req.currentUser));

        return JsonResponseOk.asShelfResponse(users);
      } catch (e) {
        return JsonResponseServerError.asShelfResponse();
      }
    })
    ..get('/user/<id>', (Request req) {
      final idParam = req.params['id'];

      if (idParam == null)
        return JsonResponseBadRequest.asShelfResponse('User ID is required');

      final id = Id(idParam);

      try {
        final user =
            _userAdministrationService.get(requester: req.currentUser, id: id);

        if (user == null)
          return JsonResponseNotFound.asShelfResponse('User not found');

        return JsonResponseOk.asShelfResponse(UserMapper.toJson(user));
      } on PolicyViolationException catch (e) {
        return JsonResponseForbidden.asShelfResponse('Forbidden: ${e.reason}');
      } catch (e) {
        return JsonResponseServerError.asShelfResponse(e.toString());
      }
    })
    ..delete('/user/<id>', (Request req) {
      final idParam = req.params['id'];

      if (idParam == null)
        return JsonResponseBadRequest.asShelfResponse('User ID is required');

      final id = Id(idParam);

      final user =
          _userAdministrationService.get(requester: req.currentUser, id: id);

      if (user == null)
        return JsonResponseNotFound.asShelfResponse('User not found');

      try {
        _userAdministrationService.deleteUser(
            requester: req.currentUser, target: user);
        return JsonResponseOk.asShelfResponse('Deleted user: $id');
      } catch (e) {
        return JsonResponseServerError.asShelfResponse(e.toString());
      }
    })
    ..post('/user/email', (Request req) {
      return req.readAsString().then((body) {
        final parts = body.split(',');
        if (parts.length != 2) {
          return JsonResponseBadRequest.asShelfResponse(
              'Expected body format: "<userId>,<newEmail>"');
        }
        final userId = parts[0].trim();
        final newEmail = parts[1].trim();

        if (userId.isEmpty || newEmail.isEmpty) {
          return JsonResponseBadRequest.asShelfResponse(
              'User ID and new email must not be empty');
        }

        final id = Id(userId);

        final user =
            _userAdministrationService.get(requester: req.currentUser, id: id);

        if (user == null) {
          return JsonResponseNotFound.asShelfResponse('User not found');
        }

        try {
          _userAdministrationService.updateUserEmail(
              requester: req.currentUser,
              target: user,
              newEmail: Email(newEmail));
          return JsonResponseOk.asShelfResponse(
              'Updated email for user: $userId');
        } on PolicyViolationException catch (e) {
          return JsonResponseForbidden.asShelfResponse(
              'Forbidden: ${e.reason}');
        } catch (e) {
          return JsonResponseServerError.asShelfResponse(e.toString());
        }
      });
    })
    ..post('/user/password', (Request req) {
      return req.readAsString().then((body) {
        final parts = body.split(',');
        if (parts.length != 2) {
          return JsonResponseBadRequest.asShelfResponse(
              'Expected body format: "<userId>,<newPassword>"');
        }
        final userId = parts[0].trim();
        final newPassword = parts[1].trim();

        if (userId.isEmpty || newPassword.isEmpty) {
          return JsonResponseBadRequest.asShelfResponse(
              'User ID and new password must not be empty');
        }

        final id = Id(userId);

        final user =
            _userAdministrationService.get(requester: req.currentUser, id: id);

        if (user == null) {
          return JsonResponseNotFound.asShelfResponse('User not found');
        }

        try {
          _userAdministrationService.updateUserPassword(
              requester: req.currentUser,
              target: user,
              newPassword: Password(newPassword));
          return JsonResponseOk.asShelfResponse(
              'Updated password for user: $userId');
        } on PolicyViolationException catch (e) {
          return JsonResponseForbidden.asShelfResponse(
              'Forbidden: ${e.reason}');
        } catch (e) {
          return JsonResponseServerError.asShelfResponse(e.toString());
        }
      });
    });
}
