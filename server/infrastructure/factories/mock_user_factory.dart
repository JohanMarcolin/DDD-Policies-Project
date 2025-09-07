import '../../../domain/entities/user.dart';
import '../../../domain/value_objects/id.dart';
import '../../../domain/value_objects/email.dart';
import '../../../domain/value_objects/password.dart';
import '../../../domain/value_objects/role.dart';

class MockUserFactory {
  static List<Map<User, Password>> createDefaultUsersWithPasswords() {
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
