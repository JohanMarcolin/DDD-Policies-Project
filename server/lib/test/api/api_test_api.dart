import 'package:domain/value_objects/role.dart';
import 'package:global_utils/error_codes.dart';
import 'package:global_utils/user_test_fixture.dart';
import 'package:global_utils/user_test_fixture_mapper.dart';
import 'package:global_utils/http_api/http_api.dart';

/// API for managing test user fixtures in Api tests.
///
/// Provides methods to create and delete user fixtures server-side, enabling
/// repeatable and isolated Api test scenarios.
class ApiTestApi extends HttpApi {
  /// Creates user fixtures for all [Role.values].
  ///
  /// Returns a list of [UserTestFixture]:s for role-based Api testing.
  /// Throws [ApiTestApiException] if the call returns an error.
  Future<List<UserTestFixture>> createAllUserFixtures() async {
    return await callPost<List<UserTestFixture>>(
      endpoint: '/test/create-all-user-fixtures',
      map: (response) {
        if (response.isSuccess) {
          return (response.data as List).map((json) => UserTestFixtureMapper.fromJson(json)).toList();
        }
        throw ApiTestApiException(response.errorCode);
      },
    );
  }

  /// Deletes all user fixtures server-side.
  ///
  /// Use this to ensure a clean state between Api tests. Throws [ApiTestApiException] on failure.
  Future<void> deleteAllUserFixtures() async {
    await callDelete<void>(
      endpoint: '/test/delete-all-user-fixtures',
      map: (response) {
        if (response.isSuccess) {
          return;
        }
        throw ApiTestApiException(response.errorCode);
      },
    );
  }

  /// Creates a user fixture with the specified [role] server-side.
  ///
  /// Returns a [UserTestFixture] containing user credentials and metadata for use in Api tests.
  /// Throws [ApiTestApiException] if the call returns an error.
  Future<UserTestFixture> createUserFixture({required Role role}) async {
    return await callPost<UserTestFixture>(
      endpoint: '/test/create-user-fixture/${role.name}',
      map: (response) {
        if (response.isSuccess) {
          return UserTestFixtureMapper.fromJson(response.data);
        }
        throw ApiTestApiException(response.errorCode);
      },
    );
  }
}

class ApiTestApiException implements Exception {
  final ErrorCode errorCode;

  ApiTestApiException(String? errorCode) : errorCode = errorCodeFromString(errorCode);
}
