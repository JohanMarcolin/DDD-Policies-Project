import 'package:domain/entities/user.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/role.dart';

typedef UserJson = Map<String, dynamic>;

class UserMapper {
  static UserJson toJson(User user) => {
        'userId': user.userId.value,
        'email': user.email.value,
        'role': user.role.name,
      };

  static List<UserJson> toJsonList(List<User> users) =>
      users.map(toJson).toList();

  static User fromJson(Map<String, dynamic> json) {
    return User(
      userId: UserId(json['userId']),
      email: Email(json['email']),
      role: Role.values.firstWhere((r) => r.name == json['role']),
      // ...other fields...
    );
  }
}
