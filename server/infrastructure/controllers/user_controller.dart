import 'package:error_codes/error_codes.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/password.dart';

import '../http/exceptions/request_exceptions.dart';
import '../http/request_utils.dart';
import '../http/response_utils.dart';
import '../mappers/user_mapper.dart';
import '../security/security_filter_chain.dart';

class UserController {
  UserController({required UserAdministrationService userAdministrationService})
      : _userAdministrationService = userAdministrationService {
    _userRouter.get('/all', _getAllUsers);
    _userRouter.get('/<userId>', _getUserById);
    _userRouter.delete('/<userId>', _deleteUser);
    _userRouter.put('/<userId>/email', _updateEmail);
    _userRouter.put('/<userId>/password', _updatePassword);
  }

  final UserAdministrationService _userAdministrationService;
  final Router _userRouter = Router();

  Handler get handler => _userRouter.call;

  Future<Response> _getAllUsers(Request req) async {
    final users =
        await _userAdministrationService.viewUsers(initiator: req.currentUser);
    return ok(UserMapper.toJsonList(users));
  }

  Future<Response> _getUserById(Request req) async {
    final user = await getTargetUser(req, _userAdministrationService);
    return ok(UserMapper.toJson(user));
  }

  Future<Response> _deleteUser(Request req) async {
    final targetUser = await getTargetUser(req, _userAdministrationService);

    await _userAdministrationService.deleteUser(
      initiator: req.currentUser,
      target: targetUser,
    );

    return ok();
  }

  Future<Response> _updateEmail(Request req) async {
    final targetUser = await getTargetUser(req, _userAdministrationService);

    final body = await readJsonBody(req);
    final newEmail = body['newEmail'] as String?;

    if (newEmail == null || newEmail.isEmpty) {
      throw BadRequestException(UpdateUserEmailMissingNewEmail());
    }
    final email = Email(newEmail);

    await _userAdministrationService.updateUserEmail(
        initiator: req.currentUser, target: targetUser, newEmail: email);

    return ok();
  }

  Future<Response> _updatePassword(Request req) async {
    final targetUser = await getTargetUser(req, _userAdministrationService);

    final body = await readJsonBody(req);

    final newPassword = body['newPassword'] as String?;

    if (newPassword == null || newPassword.isEmpty) {
      throw BadRequestException(UpdateUserPasswordMissingNewPassword());
    }

    await _userAdministrationService.updateUserPassword(
        initiator: req.currentUser,
        target: targetUser,
        newPassword: Password(newPassword));

    return ok();
  }
}
