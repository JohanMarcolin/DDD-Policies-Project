import '../../domain/entities/user.dart';
import '../../domain/value_objects/email.dart';
import '../../domain/value_objects/id.dart';
import '../../domain/value_objects/password.dart';
import '../../domain/value_objects/role.dart';
import '../../server/infrastructure/databases/user_database.dart';
import '../../server/infrastructure/databases/user_password_database.dart';

class TestUserEntry {
  const TestUserEntry({required this.user, required this.password});

  final User user;
  final Password password;

  Id get id => user.id;
  Email get email => user.email;
}

class TestUserEntryFactory {
  static User user1 = _createUser(
    id: Id('1'),
    email: Email('user1@example.com'),
    role: Role.user,
  );

  static User admin1 = _createUser(
    id: Id('2'),
    email: Email('user2@example.com'),
    role: Role.admin,
  );

  static User analyst1 = _createUser(
    id: Id('3'),
    email: Email('user3@example.com'),
    role: Role.analyst,
  );

  static List<TestUserEntry> get defaultUserEntries => _getDefaultUserEntries();

  static void setupDefaultUsers({
    required UserDatabase userDatabase,
    required UserPasswordDatabase userPasswordDatabase,
  }) {
    for (final entry in defaultUserEntries) {
      userDatabase.put(entry.id, entry.user);
      userPasswordDatabase.put(entry.id, entry.password);
    }
  }

  static List<TestUserEntry> _getDefaultUserEntries() {
    return [
      _getDefaultUserEntryWithPassword(role: Role.user),
      _getDefaultUserEntryWithPassword(role: Role.admin),
      _getDefaultUserEntryWithPassword(role: Role.analyst),
    ];
  }

  static TestUserEntry _getDefaultUserEntryWithPassword({required Role role}) {
    return TestUserEntry(
      user: User(
        id: Id(role.name),
        email: Email(role.name),
        role: role,
      ),
      password: Password(role.name),
    );
  }

  static User _createUser(
      {required Id id, required Email email, required Role role}) {
    return User(
      id: id,
      email: email,
      role: role,
    );
  }
}
