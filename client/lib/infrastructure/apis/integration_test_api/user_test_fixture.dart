part of 'integration_test_api.dart';

class UserTestFixture {
  UserTestFixture({required this.user, required this.password});

  final User user;
  final Password password;

  UserId get userId => user.userId;
  Email get email => user.email;
  Role get role => user.role;
}
