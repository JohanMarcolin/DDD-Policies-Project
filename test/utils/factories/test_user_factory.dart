import '../../../domain/entities/admin.dart';
import '../../../domain/entities/analyst.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/value_objects/email.dart';
import '../../../domain/value_objects/id.dart';
import '../../../domain/value_objects/role.dart';

class TestUserFactory {
  static final User user1 = _createUser(
    email: Email('user1@test.com'),
  );

  static final User user2 = _createUser(
    email: Email('user2@test.com'),
  );

  static final User admin1 = _createAdmin(
    email: Email('admin1@test.com'),
  );

  static final User admin2 = _createAdmin(
    email: Email('admin2@test.com'),
  );

  static final User analyst1 = _createAnalyst(
    email: Email('analyst1@test.com'),
  );

  static final User analyst2 = _createAnalyst(
    email: Email('analyst2@test.com'),
  );

  static final List<User> users = [
    user1,
    user2,
    admin1,
    admin2,
    analyst1,
    analyst2,
  ];

  static Analyst _createAnalyst({required Email email}) =>
      Analyst(userId: UserId.generate(), email: email);

  static Admin _createAdmin({required Email email}) =>
      Admin(userId: UserId.generate(), email: email);

  static User _createUser({required Email email, Role role = Role.user}) =>
      User(userId: UserId.generate(), email: email, role: role);
}
