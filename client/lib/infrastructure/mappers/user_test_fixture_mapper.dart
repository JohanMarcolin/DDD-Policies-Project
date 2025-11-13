import 'package:client/infrastructure/mappers/user_mapper.dart';
import 'package:domain/value_objects/password.dart';

import '../apis/integration_test_api/integration_test_api.dart';

class UserTestFixtureMapper {
  static UserTestFixture fromJson(Map<String, dynamic> json) {
    return UserTestFixture(user: UserMapper.toDomainUser(json), password: Password(json['password']));
  }
}
