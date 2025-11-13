import 'package:domain/entities/user.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/role.dart';

class UserMapper {
  static User toDomainUser(Map<String, dynamic> json) => User(
    userId: UserId(json['userId'].toString()),
    email: Email(json['email'] as String),
    role: Role.values.firstWhere((r) => r.name == json['role']),
  );

  static List<User> toDomainUserList(List<Map<String, dynamic>> jsonList) => jsonList.map(toDomainUser).toList();
}
