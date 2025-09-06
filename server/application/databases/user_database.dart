import '../../domain/entities/admin.dart';
import '../../domain/entities/super_admin.dart';
import '../../domain/entities/user.dart';
import '../../domain/value_objects/email.dart';
import '../../domain/value_objects/id.dart';
import '../../domain/value_objects/password.dart';
import '../../domain/value_objects/role.dart';
import 'database.dart';

class UserDatabase implements Database<User> {
  UserDatabase() {
    _setupMockUsers();
  }

  void _setupMockUsers() {
    final user1 = User(
      id: Id.generate(),
      email: Email('user'),
      password: Password('user'),
      role: Role.user,
    );
    final admin1 = Admin(
      id: Id.generate(),
      email: Email('admin'),
      password: Password('admin'),
    );
    final superAdmin1 = SuperAdmin(
      id: Id.generate(),
      email: Email('superadmin'),
      password: Password('superadmin'),
    );

    put(user1.id, user1);
    put(admin1.id, admin1);
    put(superAdmin1.id, superAdmin1);
  }

  final Map<Id, User> _users = {};

  @override
  User? get(Id id) => _users[id];

  @override
  List<User> getAll() => _users.values.toList();

  @override
  void put(Id id, User value) {
    _users[id] = value;
  }

  @override
  void delete(Id id) {
    _users.remove(id);
  }
}
