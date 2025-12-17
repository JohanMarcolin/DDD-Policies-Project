import 'package:test_utils/fixtures/user/user_test_fixture.dart';
import 'package:test_utils/fixtures/server/test_server_fixture.dart';
import 'package:test_utils/fixtures/user/user_test_fixture_api.dart';

import 'package:client/infrastructure/services/auth_token_service.dart';
import 'package:domain/value_objects/role.dart';

/// Provides setup, teardown, and test data utilities for integration tests which require a running server.
///
/// This fixture is intended exclusively for integration tests. It manages the lifecycle of the test server,
/// configures API endpoints, and exposes helpers for creating user fixtures. All methods are static for
/// convenient use in test setup/teardown blocks.
class IntegrationTestServerFixture {
  static late UserTestFixtureApi _userTestFixtureApi;
  static late AuthTokenService _authTokenService;

  /// Starts the integration test server and initializes the required dependencies.
  ///
  /// Call this in your test's `setUp` method.
  static Future<void> setup() async {
    await TestServerFixture.start(exposeTestRoutes: true);
    _authTokenService = AuthTokenService();
    _userTestFixtureApi = UserTestFixtureApi(baseUrl: TestServerFixture.baseUrl);
  }

  /// Cleans up all test data and stops the integration test server.
  ///
  /// Call this in your test's `tearDown` method to ensure a clean state between tests.
  static Future<void> teardown() async {
    await _userTestFixtureApi.deleteAllUserFixtures();
    await _authTokenService.clearTokens();
    await TestServerFixture.stop();
  }

  /// Creates a user fixture with the specified [role].
  ///
  /// Returns a [UserTestFixture].
  static Future<UserTestFixture> createUserFixture({required Role role}) async {
    return await _userTestFixtureApi.createUserFixture(role: role);
  }

  /// Creates user fixtures for all [Role.values].
  ///
  /// Returns a list of [UserTestFixture]:s.
  static Future<List<UserTestFixture>> createAllUserFixtures() async {
    return await _userTestFixtureApi.createAllUserFixtures();
  }
}
