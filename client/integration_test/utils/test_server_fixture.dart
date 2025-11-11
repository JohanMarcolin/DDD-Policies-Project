import 'package:client/infrastructure/apis/http_api.dart';
import 'package:client/infrastructure/apis/test_api.dart';
import 'package:client/infrastructure/services/auth_token_service.dart';
import 'package:domain/value_objects/role.dart';
import 'package:server/test/utils/factories/test_server_factory.dart';

class TestServerFixture {
  static late TestApi _testApi;
  static late AuthTokenService _authTokenService;

  static Future<void> setup() async {
    await TestServerFactory.start(enableTestRoutes: true);
    HttpApi.baseUrl = TestServerFactory.baseUrl;
    _testApi = TestApi();
    _authTokenService = AuthTokenService();
  }

  static Future<void> teardown() async {
    await _testApi.deleteAllUserFixtures();
    await _authTokenService.clearTokens();
    await TestServerFactory.stop();
  }

  static Future<UserTestFixture> createUserFixture({required Role role}) async {
    return await _testApi.createUserFixture(role: role);
  }

  static Future<List<UserTestFixture>> createAllUserFixtures() async {
    return await _testApi.createAllUserFixtures();
  }
}
