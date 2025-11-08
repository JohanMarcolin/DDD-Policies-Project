import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/test_service.dart';

class TestController {
  TestController({required TestService testService})
      : _testService = testService {
    _testRouter.post('/create-all-user-pairs', _createAllUserPairs);
    _testRouter.delete('/delete-all-users', _deleteAllUsers);
    _testRouter.post('/create-user', _createUser);
    _testRouter.delete('/delete/<userId>', _deleteUser);
  }

  final TestService _testService;
  final Router _testRouter = Router();

  Handler get handler => _testRouter.call;

  Future<Response> _createAllUserPairs(Request req) async {
    return await _testService.createAllUserPairs(req);
  }

  Future<Response> _deleteAllUsers(Request req) async {
    return await _testService.deleteAllUsers(req);
  }

  Future<Response> _createUser(Request req) async {
    return await _testService.createUser(req);
  }

  Future<Response> _deleteUser(Request req) async {
    return await _testService.deleteUser(req);
  }
}
