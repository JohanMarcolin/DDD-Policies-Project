import 'package:domain/value_objects/password.dart';
import 'package:test_utils/fixtures/user/user_test_fixture.dart';
import 'user_mapper.dart';

/// Utility class for converting between [UserTestFixture]:s and their equivalent json.
class UserTestFixtureMapper {
  /// Creates a [UserTestFixture] from a json map.
  ///
  /// The [json] must contain user fields and a password.
  static UserTestFixture fromJson(Map<String, dynamic> json) {
    return UserTestFixture(user: UserMapper.toDomainUser(json), password: Password(json['password']));
  }
}
