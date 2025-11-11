import 'package:client/infrastructure/apis/http_api.dart';
import 'package:client/infrastructure/mappers/user_mapper.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/password.dart';
import 'package:domain/value_objects/role.dart';
import 'package:error_codes/error_codes.dart';

class TestApi extends HttpApi {
  Future<List<UserTestFixture>> createAllUserFixtures() async {
    return await callPost<List<UserTestFixture>>(
      endpoint: '/test/create-all-user-fixtures',
      map: (response) {
        if (response.isSuccess) {
          return (response.data as List)
              .map((e) => UserTestFixture.fromJson(e))
              .toList();
        }
        throw TestApiException(response.errorCode!);
      },
    );
  }

  Future<void> deleteAllUserFixtures() async {
    await callDelete<void>(
      endpoint: '/test/delete-all-user-fixtures',
      map: (response) {
        if (response.isSuccess) {
          return;
        }
        throw TestApiException(response.errorCode!);
      },
    );
  }

  Future<UserTestFixture> createUserFixture({required Role role}) async {
    return await callPost<UserTestFixture>(
      endpoint: '/test/create-user-fixture/${role.name}',
      map: (response) {
        if (response.isSuccess) {
          return UserTestFixture.fromJson(response.data);
        }
        throw TestApiException(response.errorCode!);
      },
    );
  }
}

class TestApiException implements Exception {
  final ErrorCode errorCode;
  TestApiException(String errorCode)
    : errorCode = errorCodeFromString(errorCode);
}

class UserTestFixture {
  final User user;
  final Password password;

  UserTestFixture({required this.user, required this.password});

  factory UserTestFixture.fromJson(Map<String, dynamic> json) {
    return UserTestFixture(
      user: UserMapper.toDomainUser(json),
      password: Password(json['password']),
    );
  }

  UserId get userId => user.userId;
  Email get email => user.email;
  Role get role => user.role;
}
