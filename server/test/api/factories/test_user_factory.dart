import '../../../../domain/entities/user.dart';
import '../../../../domain/value_objects/id.dart';
import '../../../../domain/value_objects/email.dart';
import '../../../../domain/value_objects/password.dart';
import '../../../../domain/value_objects/role.dart';
import '../../../infrastructure/databases/user_database.dart';
import '../../../infrastructure/databases/user_password_database.dart';

class TestUserEntry {
  const TestUserEntry({required this.user, required this.password});

  final User user;
  final Password password;

  Id get id => user.id;
  Email get email => user.email;
}

class TestUserFactory {
  static List<TestUserEntry> get defaultUserEntries =>
      _createDefaultUserEntries();

  static void setupDefaultUsers({
    required UserDatabase userDatabase,
    required UserPasswordDatabase userPasswordDatabase,
  }) {
    for (final entry in defaultUserEntries) {
      userDatabase.put(entry.id, entry.user);
      userPasswordDatabase.put(entry.id, entry.password);
    }
  }

  static List<TestUserEntry> _createDefaultUserEntries() {
    return [
      _createUserEntryWithPassword(role: Role.user),
      _createUserEntryWithPassword(role: Role.admin),
      _createUserEntryWithPassword(role: Role.analyst),
    ];
  }

  static TestUserEntry _createUserEntryWithPassword({required Role role}) {
    return TestUserEntry(
      user: User(
        id: Id.generate(),
        email: Email(role.name),
        role: role,
      ),
      password: Password(role.name),
    );
  }
}
