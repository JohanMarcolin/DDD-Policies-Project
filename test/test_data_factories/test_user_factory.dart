import '../../domain/entities/admin.dart';
import '../../domain/entities/analyst.dart';
import '../../domain/entities/user.dart';
import '../../domain/value_objects/email.dart';
import '../../domain/value_objects/id.dart';
import '../../domain/value_objects/role.dart';

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

  static Analyst _createAnalyst({required Email email}) =>
      Analyst(id: Id.generate(), email: email);

  static Admin _createAdmin({required Email email}) =>
      Admin(id: Id.generate(), email: email);

  static User _createUser({required Email email, Role role = Role.user}) =>
      User(id: Id.generate(), email: email, role: role);
}
