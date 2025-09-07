import '../../domain/entities/admin.dart';
import '../../domain/entities/analyst.dart';
import '../../domain/entities/user.dart';
import '../../domain/value_objects/id.dart';
import '../../domain/value_objects/email.dart';
import '../../domain/value_objects/role.dart';

class MockUserFactory {
  static User createUser({String email = 'user', String password = 'user'}) {
    return User(
      id: Id.generate(),
      email: Email(email),
      role: Role.user,
    );
  }

  static Admin createAdmin(
      {String email = 'admin', String password = 'admin'}) {
    return Admin(
      id: Id.generate(),
      email: Email(email),    );
  }

  static Analyst createAnalyst(
      {String email = 'analyst', String password = 'analyst'}) {
    return Analyst(
      id: Id.generate(),
      email: Email(email),    );
  }

  static List<User> createDefaultUsers() {
    return [
      createUser(),
      createAdmin(),
      createAnalyst(),
    ];
  }
}
