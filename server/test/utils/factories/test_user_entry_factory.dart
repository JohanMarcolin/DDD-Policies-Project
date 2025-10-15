import 'package:domain/entities/user.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/password.dart';
import 'package:domain/value_objects/role.dart';
import '../../../infrastructure/databases/user_database.dart';
import '../../../infrastructure/databases/user_password_database.dart';

class TestUserEntry {
  const TestUserEntry({required this.user, required this.password});

  final User user;
  final Password password;

  UserId get userId => user.userId;
  Email get email => user.email;
}

class TestUserEntryFactory {
  static User user1 = _createUser(
    userId: UserId('1'),
    email: Email('user1@example.com'),
    role: Role.user,
  );

  static User admin1 = _createUser(
    userId: UserId('2'),
    email: Email('user2@example.com'),
    role: Role.admin,
  );

  static User analyst1 = _createUser(
    userId: UserId('3'),
    email: Email('user3@example.com'),
    role: Role.analyst,
  );

  static List<TestUserEntry> get defaultUserEntries => _getDefaultUserEntries();

  static void setupDefaultUsers({
    required UserDatabase userDatabase,
    required UserPasswordDatabase userPasswordDatabase,
  }) {
    for (final entry in defaultUserEntries) {
      userDatabase.put(entry.userId, entry.user);
      userPasswordDatabase.put(entry.userId, entry.password);
    }
  }

  static List<TestUserEntry> _getDefaultUserEntries() {
    return [
      _getDefaultUserEntryWithPassword(role: Role.user, number: 1),
      _getDefaultUserEntryWithPassword(role: Role.user, number: 2),
      _getDefaultUserEntryWithPassword(role: Role.admin, number: 1),
      _getDefaultUserEntryWithPassword(role: Role.admin, number: 2),
      _getDefaultUserEntryWithPassword(role: Role.analyst, number: 1),
      _getDefaultUserEntryWithPassword(role: Role.analyst, number: 2),
    ];
  }

  static TestUserEntry _getDefaultUserEntryWithPassword(
      {required Role role, required int number}) {
    final roleName = role.name;
    return TestUserEntry(
      user: User(
        userId: UserId('$roleName$number'),
        email: Email('$roleName$number'),
        role: role,
      ),
      password: Password('$roleName$number'),
    );
  }

  static User _createUser(
      {required UserId userId, required Email email, required Role role}) {
    return User(
      userId: userId,
      email: email,
      role: role,
    );
  }
}
