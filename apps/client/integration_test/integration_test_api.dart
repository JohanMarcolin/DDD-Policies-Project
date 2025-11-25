import 'package:domain/value_objects/role.dart';
import 'package:api_error_codes/api_error_codes.dart';
import 'package:mappers/user_test_fixture_mapper.dart';
import 'package:test_utils/user_test_fixture.dart';
import 'package:http_api/http_api.dart';

/// API for managing test user fixtures in integration tests.
///
/// Provides methods to create and delete user fixtures server-side, enabling
/// repeatable and isolated integration test scenarios.
class IntegrationTestApi extends HttpApi {
  /// Creates user fixtures for all [Role.values].
  ///
  /// Returns a list of [UserTestFixture]:s for role-based integration testing.
  /// Throws [IntegrationTestApiException] if the call returns an error.
  Future<List<UserTestFixture>> createAllUserFixtures() async {
    return await callPost<List<UserTestFixture>>(
      endpoint: '/test/create-all-user-fixtures',
      map: (response) {
        if (response.isSuccess) {
          return (response.data as List).map((json) => UserTestFixtureMapper.fromJson(json)).toList();
        }
        throw IntegrationTestApiException(response.apiErrorCode);
      },
    );
  }

  /// Deletes all user fixtures server-side.
  ///
  /// Use this to ensure a clean state between integration tests. Throws [IntegrationTestApiException] on failure.
  Future<void> deleteAllUserFixtures() async {
    await callDelete<void>(
      endpoint: '/test/delete-all-user-fixtures',
      map: (response) {
        if (response.isSuccess) {
          return;
        }
        throw IntegrationTestApiException(response.apiErrorCode);
      },
    );
  }

  /// Creates a user fixture with the specified [role] server-side.
  ///
  /// Returns a [UserTestFixture] containing user credentials and metadata for use in integration tests.
  /// Throws [IntegrationTestApiException] if the call returns an error.
  Future<UserTestFixture> createUserFixture({required Role role}) async {
    return await callPost<UserTestFixture>(
      endpoint: '/test/create-user-fixture/${role.name}',
      map: (response) {
        if (response.isSuccess) {
          return UserTestFixtureMapper.fromJson(response.data);
        }
        throw IntegrationTestApiException(response.apiErrorCode);
      },
    );
  }
}

class IntegrationTestApiException extends ApiException {
  IntegrationTestApiException(super.apiErrorCode);
}
