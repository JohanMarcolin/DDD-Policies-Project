import 'package:domain/value_objects/password.dart';
import 'package:global_utils/mappers/user_mapper.dart';
import 'package:global_utils/test/user_test_fixture.dart';

class UserTestFixtureMapper {
  static UserTestFixture fromJson(Map<String, dynamic> json) {
    return UserTestFixture(user: UserMapper.toDomainUser(json), password: Password(json['password']));
  }
}
