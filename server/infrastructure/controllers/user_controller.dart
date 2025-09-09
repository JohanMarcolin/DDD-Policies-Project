import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../../domain/services/user_administration/user_administration_service.dart';
import '../../../domain/value_objects/email.dart';
import '../http/exceptions/request_exceptions.dart';
import '../http/request_utils.dart';
import '../http/response_utils.dart';
import '../mappers/user_mapper.dart';
import '../security/security_filter_chain.dart';

class UserController {
  UserController({required UserAdministrationService userAdministrationService})
      : _userAdministrationService = userAdministrationService {
    _userRouter.get('/all', _getAllUsers);
    _userRouter.get('/<id>', _getUserById);
    _userRouter.delete('/<id>', _deleteUser);
    _userRouter.post('/<id>/email', _updateEmail);
    _userRouter.post('/<id>/password', _updatePassword);
  }

  final UserAdministrationService _userAdministrationService;
  final Router _userRouter = Router();

  Handler get handler => _userRouter;

  Future<Response> _getAllUsers(Request req) async {
    final users =
        _userAdministrationService.getUsers(requester: req.currentUser);
    return ok(UserMapper.toJsonList(users));
  }

  Future<Response> _getUserById(Request req) async {
    final user = getTargetUser(req, _userAdministrationService);
    return ok(UserMapper.toJson(user));
  }

  Future<Response> _deleteUser(Request req) async {
    final user = getTargetUser(req, _userAdministrationService);

    _userAdministrationService.deleteUser(
        requester: req.currentUser, target: user);

    return ok('Deleted user: ${user.id.value}');
  }

  Future<Response> _updateEmail(Request req) async {
    final id = extractIdFromParams(req);

    final body = await readJsonBody(req);

    final newEmail = body['newEmail'] as String?;

    if (newEmail == null || newEmail.isEmpty) {
      throw BadRequestException('Missing or empty new email');
    }
    final email = Email(newEmail);

    final user =
        _userAdministrationService.get(requester: req.currentUser, id: id);
    if (user == null) throw NotFoundException('User not found');

    _userAdministrationService.updateUserEmail(
        requester: req.currentUser, target: user, newEmail: email);
    return ok({
      'message':
          'Updated email for user: ${id.value} from ${user.email.value} to ${email.value}'
    });
  }

  Future<Response> _updatePassword(Request req) async {
    final id = extractIdFromParams(req);

    final body = await readJsonBody(req);

    final newPassword = body['newPassword'] as String?;

    if (newPassword == null || newPassword.isEmpty) {
      throw BadRequestException('Missing or empty new password');
    }

    final user =
        _userAdministrationService.get(requester: req.currentUser, id: id);
    if (user == null) throw NotFoundException('User not found');

    return ok('Updated password for user: ${id.value}');
  }
}
