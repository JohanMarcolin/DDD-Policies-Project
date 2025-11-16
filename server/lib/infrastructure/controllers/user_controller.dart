import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/user_service.dart';

/// Controller for user administration endpoints.
///
/// Provides RESTful routes for user administration:
/// - `GET /all`: Returns all users.
/// - `GET /<userId>`: Returns details for a specific user.
/// - `DELETE /<userId>`: Deletes a user by ID.
/// - `PUT /<userId>/email`: Updates a user's email address.
/// - `PUT /<userId>/password`: Updates a user's password.
class UserController {
  UserController({required UserService userService}) : _userService = userService {
    _userRouter.get('/all', _getAllUsers);
    _userRouter.get('/<userId>', _getUserById);
    _userRouter.delete('/<userId>', _deleteUser);
    _userRouter.put('/<userId>/email', _updateEmail);
    _userRouter.put('/<userId>/password', _updatePassword);
  }

  final UserService _userService;
  final Router _userRouter = Router();

  Handler get handler => _userRouter.call;

  Future<Response> _getAllUsers(Request req) async {
    return await _userService.getAllUsers(req);
  }

  Future<Response> _getUserById(Request req) async {
    return await _userService.getUserById(req);
  }

  Future<Response> _deleteUser(Request req) async {
    return await _userService.deleteUser(req);
  }

  Future<Response> _updateEmail(Request req) async {
    return await _userService.updateEmail(req);
  }

  Future<Response> _updatePassword(Request req) async {
    return await _userService.updatePassword(req);
  }
}
