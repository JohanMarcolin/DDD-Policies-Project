import 'package:domain/value_objects/password.dart';
import 'package:test_utils/user_test_fixture.dart';
import 'user_mapper.dart';

/// Utility class for converting between [UserTestFixture] objects and their equivalent JSON.
class UserTestFixtureMapper {
  /// Creates a [UserTestFixture] from a JSON map.
  ///
  /// The [json] must contain user fields and a password.
  static UserTestFixture fromJson(Map<String, dynamic> json) {
    return UserTestFixture(user: UserMapper.toDomainUser(json), password: Password(json['password']));
  }
}
