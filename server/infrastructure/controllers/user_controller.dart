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
        await _userAdministrationService.getUsers(initiator: req.currentUser);
    return ok(UserMapper.toJsonList(users));
  }

  Future<Response> _getUserById(Request req) async {
    final user = await getTargetUser(req, _userAdministrationService);
    return ok(UserMapper.toJson(user));
  }

  Future<Response> _deleteUser(Request req) async {
    final userId = extractUserIdFromParams(req);

    await _userAdministrationService.deleteUser(
      initiator: req.currentUser,
      userId: userId,
    );

    return ok('Deleted user: ${userId.value}');
  }

  Future<Response> _updateEmail(Request req) async {
    final userId = extractUserIdFromParams(req);

    final body = await readJsonBody(req);

    final newEmail = body['newEmail'] as String?;

    if (newEmail == null || newEmail.isEmpty) {
      throw BadRequestException('Missing or empty new email');
    }
    final email = Email(newEmail);

    final user = await _userAdministrationService.get(
        initiator: req.currentUser, userId: userId);
    if (user == null) throw NotFoundException('User not found');

    await _userAdministrationService.updateUserEmail(
        initiator: req.currentUser, userId: user.userId, newEmail: email);
    return ok({
      'message':
          'Updated email for user: ${userId.value} from ${user.email.value} to ${email.value}'
    });
  }

  Future<Response> _updatePassword(Request req) async {
    final userId = extractUserIdFromParams(req);

    final body = await readJsonBody(req);

    final newPassword = body['newPassword'] as String?;

    if (newPassword == null || newPassword.isEmpty) {
      throw BadRequestException('Missing or empty new password');
    }

    final user = await _userAdministrationService.get(
        initiator: req.currentUser, userId: userId);

    if (user == null) throw NotFoundException('User not found');

    await _userAdministrationService.updateUserPassword(
        initiator: req.currentUser,
        userId: userId,
        newPassword: Password(newPassword));

    return ok('Updated password for user: ${userId.value}');
  }
}
