import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/test_service.dart';

/// Controller for test utility endpoints.
///
/// Provides routes for managing test user fixtures:
/// - `POST /create-all-user-fixtures`: Creates all user fixtures for all roles.
/// - `DELETE /delete-all-user-fixtures`: Deletes all user fixtures from the test database.
/// - `POST /create-user-fixture/<roleName>`: Creates a user fixture for the specified role.
class TestController {
  TestController({required TestService testService}) : _testService = testService {
    _testRouter.post('/create-all-user-fixtures', _createAllUserFixtures);
    _testRouter.delete('/delete-all-user-fixtures', _deleteAllUserFixtures);
    _testRouter.post('/create-user-fixture/<roleName>', _createUserFixture);
  }

  final TestService _testService;
  final Router _testRouter = Router();

  Handler get handler => _testRouter.call;

  Future<Response> _createAllUserFixtures(Request req) async {
    return await _testService.createAllUserFixtures(req);
  }

  Future<Response> _deleteAllUserFixtures(Request req) async {
    return await _testService.deleteAllUserFixtures(req);
  }

  Future<Response> _createUserFixture(Request req) async {
    return await _testService.createUserFixture(req);
  }
}
