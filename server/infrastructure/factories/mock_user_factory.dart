import '../../../domain/entities/user.dart';
import '../../../domain/value_objects/id.dart';
import '../../../domain/value_objects/email.dart';
import '../../../domain/value_objects/password.dart';
import '../../../domain/value_objects/role.dart';
import '../databases/user_database.dart';
import '../databases/user_password_database.dart';

class MockUserFactory {
  static void setupDefaultUsers({
    required UserDatabase userDatabase,
    required UserPasswordDatabase userPasswordDatabase,
  }) {
    for (final entry in _createDefaultUsersWithPasswords()) {
      final user = entry.keys.first;
      final password = entry.values.first;

      userDatabase.put(user.id, user);
      userPasswordDatabase.put(user.id, password);
    }
  }

  static List<Map<User, Password>> _createDefaultUsersWithPasswords() {
    return [
      _createUserWithPassword(role: Role.user),
      _createUserWithPassword(role: Role.admin),
      _createUserWithPassword(role: Role.analyst),
    ];
  }

  static Map<User, Password> _createUserWithPassword({required Role role}) {
    return {
      User(
        id: Id.generate(),
        email: Email(role.name),
        role: role,
      ): Password(role.name),
    };
  }
}
