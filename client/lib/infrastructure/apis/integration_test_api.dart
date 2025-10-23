import 'package:client/infrastructure/apis/http_api.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/password.dart';
import 'package:domain/value_objects/role.dart';

class IntegrationTestApi extends HttpApi {
  Future<List<TestUserEntry>> get testUserEntries async {
    return await callGet<List<TestUserEntry>>(
      endpoint: '/test/user-entries',
      map: (response) {
        print(response);
        if (response.isSuccess) {
          final entries = response.data as List<Map<String, dynamic>>;
          final result = entries
              .map<TestUserEntry>((json) => TestUserEntry.fromJson(json))
              .toList();
          print(result);
          return result;
        }
        throw Exception('Could not fetch test user entries');
      },
    );
  }
}

class TestUserEntry {
  final User user;
  final Password password;

  TestUserEntry({required this.user, required this.password});

  factory TestUserEntry.fromJson(Map<String, dynamic> json) {
    return TestUserEntry(
      user: User(
        userId: UserId(json['userId']),
        email: Email(json['email']),
        role: Role.values.firstWhere((r) => r.name == json['role']),
      ),
      password: Password(json['password']),
    );
  }
}
