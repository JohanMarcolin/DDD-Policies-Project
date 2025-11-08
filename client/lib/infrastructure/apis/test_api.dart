import 'package:client/infrastructure/apis/http_api.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/password.dart';
import 'package:domain/value_objects/role.dart';
import 'package:error_codes/error_codes.dart';

class TestApi extends HttpApi {
  Future<List<TestUserEntry>> createAllUserPairs() async {
    return await callPost<List<TestUserEntry>>(
      endpoint: '/test/create-all-user-pairs',
      map: (response) {
        if (response.isSuccess) {
          return (response.data as List)
              .map((e) => TestUserEntry.fromJson(e))
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

  Future<TestUserEntry> createTestUserEntry() async {
    return await callPost<TestUserEntry>(
      endpoint: '/test/create-user',
      map: (response) {
        if (response.isSuccess) {
          return TestUserEntry.fromJson(response.data);
        }
        throw TestApiException(response.errorCode!);
      },
    );
  }

  Future<void> deleteTestUserEntry({required UserId userId}) async {
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

class TestUserEntry {
  final UserId userId;
  final Email email;
  final Role role;
  final Password password;

  TestUserEntry({
    required this.userId,
    required this.email,
    required this.role,
    required this.password,
  });

  factory TestUserEntry.fromJson(Map<String, dynamic> json) {
    return TestUserEntry(
      userId: UserId(json['userId']),
      email: Email(json['email']),
      role: Role.values.firstWhere((role) => role.name == json['role']),
      password: Password(json['password']),
    );
  }
}
