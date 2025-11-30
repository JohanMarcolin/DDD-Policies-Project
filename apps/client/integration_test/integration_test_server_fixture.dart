import 'package:test_utils/user_test_fixture.dart';
import 'package:http_api/http_api.dart';
import 'package:test_utils/server/test_server_fixture.dart';

import 'integration_test_api.dart';
import 'package:client/infrastructure/services/auth_token_service.dart';
import 'package:domain/value_objects/role.dart';

/// Provides setup, teardown, and test data utilities for e2e integration tests.
///
/// This fixture should be used only for e2e integration tests. It manages the lifecycle of the test server,
/// configures API endpoints, and exposes helpers for creating user fixtures.
class IntegrationTestServerFixture {
  static late IntegrationTestApi _integrationTestApi;
  static late AuthTokenService _authTokenService;

  /// Starts the server and initializes API clients.
  ///
  /// Call this in your test's `setUp` method.
  static Future<void> setup() async {
    await TestServerFixture.start(exposeTestRoutes: true);
    HttpApi.baseUrl = TestServerFixture.baseUrl;
    _integrationTestApi = IntegrationTestApi();
    _authTokenService = AuthTokenService();
  }

  /// Cleans up all test data and stops the integration test server.
  ///
  /// Call this in your test's `tearDown` method to ensure a clean state between tests.
  static Future<void> teardown() async {
    await _integrationTestApi.deleteAllUserFixtures();
    await _authTokenService.clearTokens();
    await TestServerFixture.stop();
  }

  /// Creates a user fixture with the specified [role] server-side.
  ///
  /// Returns a [UserTestFixture].
  static Future<UserTestFixture> createUserFixture({required Role role}) async {
    return await _integrationTestApi.createUserFixture(role: role);
  }

  /// Creates user fixtures for all [Role.values].
  ///
  /// Returns a list of [UserTestFixture]:s.
  static Future<List<UserTestFixture>> createAllUserFixtures() async {
    return await _integrationTestApi.createAllUserFixtures();
  }
}
