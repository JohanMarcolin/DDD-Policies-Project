import 'package:domain/value_objects/role.dart';
import 'package:global_utils/test/test_server_fixture.dart';
import 'package:global_utils/test/user_test_fixture.dart';
import 'package:global_utils/http_api/http_api.dart';
import 'package:server/test/api/api_test_api.dart';

/// Provides setup, teardown, and test data utilities for Api tests requiring a running backend server.
///
/// This fixture is intended exclusively for Api tests. It manages the lifecycle of the test server,
/// configures API endpoints, and exposes helpers for creating user fixtures. All methods are static for
/// convenient use in test setup/teardown blocks.
class ApiTestServerFixture {
  static late ApiTestApi _apiTestApi;
  static late String _baseUrl;

  static String get baseUrl => _baseUrl;

  /// Starts the Api test server and initializes API clients.
  ///
  /// Call this in your test's `setUp` method before any test logic that requires backend access.
  static Future<void> setup() async {
    await TestServerFixture.start(enableTestRoutes: true);
    _baseUrl = TestServerFixture.baseUrl;
    HttpApi.baseUrl = _baseUrl;
    _apiTestApi = ApiTestApi();
  }

  /// Cleans up all test data and stops the Api test server.
  ///
  /// Call this in your test's `tearDown` method to ensure a clean state between tests.
  static Future<void> teardown() async {
    await _apiTestApi.deleteAllUserFixtures();
    await TestServerFixture.stop();
  }

  /// Creates a user fixture with the specified [role] on the backend test server.
  ///
  /// Returns a [UserTestFixture] containing user credentials and metadata for use in Api tests.
  static Future<UserTestFixture> createUserFixture({required Role role}) async {
    return await _apiTestApi.createUserFixture(role: role);
  }

  /// Creates user fixtures for all roles defined in the domain model.
  ///
  /// Returns a list of [UserTestFixture] objects for comprehensive role-based Api testing.
  static Future<List<UserTestFixture>> createAllUserFixtures() async {
    return await _apiTestApi.createAllUserFixtures();
  }
}
