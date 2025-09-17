import 'package:domain/entities/user.dart';

typedef UserJson = Map<String, dynamic>;

class UserMapper {
  static UserJson toJson(User user) => {
        'id': user.userId.value,
        'email': user.email.value,
        'role': user.role.name,
      };

  static List<UserJson> toJsonList(List<User> users) =>
      users.map(toJson).toList();
}
