import 'package:domain/value_objects/password.dart';
import 'package:test_utils/user_test_fixture.dart';
import 'user_mapper.dart';

class UserTestFixtureMapper {
  static UserTestFixture fromJson(Map<String, dynamic> json) {
    return UserTestFixture(user: UserMapper.toDomainUser(json), password: Password(json['password']));
  }
}
