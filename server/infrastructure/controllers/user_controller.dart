import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../../domain/policies/policy_violation_exception.dart';
import '../../../domain/services/user_administration/user_administration_service.dart';
import '../../../domain/value_objects/id.dart';
import '../http/response_utils.dart';
import '../mappers/user_mapper.dart';
import '../security/security_filter_chain.dart';

class UserController {
  UserController({required UserAdministrationService userAdministrationService})
      : _userAdministrationService = userAdministrationService {
    _userRouter.get('/all', _getAllUsers);
    _userRouter.get('/<id>', _getUserById);
    _userRouter.delete('/<id>', _deleteUser);
    _userRouter.post('/email', _updateEmail);
    _userRouter.post('/password', _updatePassword);
  }

  final UserAdministrationService _userAdministrationService;
  final Router _userRouter = Router();

  Handler get handler => _userRouter;

  Future<Response> _getAllUsers(Request req) async {
    try {
      final users = UserMapper.toJsonList(
        _userAdministrationService.getUsers(requester: req.currentUser),
      );
      return ok({'users': users});
    } catch (e) {
      return serverError();
    }
  }

  Future<Response> _getUserById(Request req) async {
    final idParam = req.params['id'];
    if (idParam == null) {
      return badRequest({'message': 'User ID is required'});
    }
    final id = Id(idParam);
    try {
      final user =
          _userAdministrationService.get(requester: req.currentUser, id: id);
      if (user == null) {
        return notFound({'message': 'User not found'});
      }
      return ok(UserMapper.toJson(user));
    } on PolicyViolationException catch (e) {
      return forbidden({'message': e.reason});
    } catch (e) {
      return serverError();
    }
  }

  Future<Response> _deleteUser(Request req) async {
    final id = req.params['id'];
    // Implement delete logic here
    return ok({'message': 'Deleted user: $id'});
  }

  Future<Response> _updateEmail(Request req) async {
    final newEmail = await req.readAsString();
    // Implement update email logic here
    return ok({'message': 'Received new email: $newEmail'});
  }

  Future<Response> _updatePassword(Request req) async {
    final newPassword = await req.readAsString();
    // Implement update password logic here
    return ok({'message': 'Received new password: $newPassword'});
  }
}
