import 'package:domain/entities/user.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/role.dart';

typedef UserJson = Map<String, dynamic>;

/// Utility class for converting between [User] objects and their equivalent JSON.
class UserMapper {
  /// Converts a [User] object to a JSON map.
  static UserJson toJson(User user) => {
        'userId': user.userId.value,
        'email': user.email.value,
        'role': user.role.name,
      };

  /// Converts a list of [User] objects to a list of JSON maps.
  static List<UserJson> toJsonList(List<User> users) => users.map(toJson).toList();

  /// Creates a [User] object from a JSON map.
  static User fromJson(Map<String, dynamic> json) {
    return User(
      userId: UserId(json['userId']),
      email: Email(json['email']),
      role: Role.values.firstWhere((r) => r.name == json['role']),
    );
  }

  /// Converts a JSON map to a [User] object.
  static User toDomainUser(Map<String, dynamic> json) => User(
        userId: UserId(json['userId'].toString()),
        email: Email(json['email'] as String),
        role: Role.values.firstWhere((r) => r.name == json['role']),
      );

  /// Converts a list of JSON maps to a list of [User] objects.
  static List<User> toDomainUserList(List<Map<String, dynamic>> jsonList) => jsonList.map(toDomainUser).toList();
}
