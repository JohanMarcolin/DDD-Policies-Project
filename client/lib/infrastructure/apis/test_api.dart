import 'package:client/infrastructure/apis/http_api.dart';
import 'package:client/infrastructure/mappers/user_mapper.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/password.dart';
import 'package:error_codes/error_codes.dart';

class TestApi extends HttpApi {
  Future<List<UserEntry>> createAllUserPairs() async {
    return await callPost<List<UserEntry>>(
      endpoint: '/test/create-all-user-pairs',
      map: (response) {
        if (response.isSuccess) {
          return (response.data as List)
              .map((e) => UserEntry.fromJson(e))
              .toList();
        }
        throw TestApiException(response.errorCode!);
      },
    );
  }

  Future<void> deleteAllTestUsers() async {
    await callDelete<void>(
      endpoint: '/test/delete-all-users',
      map: (response) {
        if (response.isSuccess) {
          return;
        }
        throw TestApiException(response.errorCode!);
      },
    );
  }

  Future<UserEntry> createUserEntry() async {
    return await callPost<UserEntry>(
      endpoint: '/test/create-user',
      map: (response) {
        if (response.isSuccess) {
          return UserEntry.fromJson(response.data);
        }
        throw TestApiException(response.errorCode!);
      },
    );
  }

  Future<void> deleteUserEntry({required UserId userId}) async {
    await callDelete<void>(
      endpoint: '/test/delete/${userId.value}',
      map: (response) {
        if (response.isSuccess) {
          return;
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

class UserEntry {
  final User user;
  final Password password;

  UserEntry({required this.user, required this.password});

  factory UserEntry.fromJson(Map<String, dynamic> json) {
    return UserEntry(
      user: UserMapper.toDomainUser(json),
      password: Password(json['password']),
    );
  }
}
