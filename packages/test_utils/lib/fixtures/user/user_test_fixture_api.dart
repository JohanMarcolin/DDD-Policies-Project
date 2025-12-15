import 'package:domain/value_objects/role.dart';
import 'package:api_error_codes/api_error_codes.dart';
import 'package:mappers/user_test_fixture_mapper.dart';
import 'package:test_utils/fixtures/user/user_test_fixture.dart';
import 'package:http_api/http_api.dart';

/// API for managing user test fixtures in API tests.
///
/// Provides methods to create and delete user test fixtures server-side, enabling
/// isolated test scenarios.
class UserTestFixtureApi extends HttpApi {
  UserTestFixtureApi({required String baseUrl}) : _baseUrl = baseUrl {
    HttpApi.baseUrl = baseUrl;
  }

  final String _baseUrl;

  String get baseUrl => _baseUrl;

  /// Creates user fixtures for all [Role.values].
  ///
  /// Returns a list of [UserTestFixture]:s for role-based Api testing.
  /// Throws [UserTestFixtureApiException] if the call returns an error.
  Future<List<UserTestFixture>> createAllUserFixtures() async {
    return await callPost<List<UserTestFixture>>(
      endpoint: '/test/create-all-user-fixtures',
      map: (response) {
        if (response.isSuccess) {
          return (response.data as List).map((json) => UserTestFixtureMapper.fromJson(json)).toList();
        }
        throw UserTestFixtureApiException(response.apiErrorCode);
      },
    );
  }

  /// Deletes all user fixtures server-side.
  ///
  /// Use this to ensure a clean state between Api tests. Throws [UserTestFixtureApiException] on failure.
  Future<void> deleteAllUserFixtures() async {
    await callDelete<void>(
      endpoint: '/test/delete-all-user-fixtures',
      map: (response) {
        if (response.isSuccess) {
          return;
        }
        throw UserTestFixtureApiException(response.apiErrorCode);
      },
    );
  }

  /// Creates a user fixture with the specified [role] server-side.
  ///
  /// Returns a [UserTestFixture] containing user credentials and metadata for use in Api tests.
  /// Throws [UserTestFixtureApiException] if the call returns an error.
  Future<UserTestFixture> createUserFixture({required Role role}) async {
    return await callPost<UserTestFixture>(
      endpoint: '/test/create-user-fixture/${role.name}',
      map: (response) {
        if (response.isSuccess) {
          return UserTestFixtureMapper.fromJson(response.data);
        }
        throw UserTestFixtureApiException(response.apiErrorCode);
      },
    );
  }
}

class UserTestFixtureApiException extends ApiException {
  UserTestFixtureApiException(super.apiErrorCode);
}
