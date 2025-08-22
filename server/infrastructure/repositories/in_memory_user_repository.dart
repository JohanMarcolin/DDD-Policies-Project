import '../../../db/in_memory_db.dart';
import '../../domain/entities/admin.dart';
import '../../domain/entities/super_admin.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/value_objects/email.dart';
import '../../domain/value_objects/id.dart';
import '../../domain/value_objects/password.dart';
import '../../domain/value_objects/role.dart';

class InMemoryUserRepository implements UserRepository {
  InMemoryUserRepository(InMemoryDb<User> db) : _db = db {
    _setupMockUsers();
  }

  final InMemoryDb<User> _db;

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

    _db.put(user1.id.value, user1);
    _db.put(admin1.id.value, admin1);
    _db.put(superAdmin1.id.value, superAdmin1);
  }

  @override
  User? getById(Id id) {
    return _db.get(id.value);
  }

  @override
  User? getByEmail(Email email) {
    final users = _db.getAll();
    
    return users.firstWhere((user) => user.email.value == email.value);
  }

  @override
  List<Admin> get admins {
    final users = _db.getAll();

    return users.where((user) => user.role is Admin).cast<Admin>().toList();
  }

  @override
  void create(Email email, Password password, Role role) {
    final id = Id.generate();
    final user = User(id: id, email: email, password: password, role: role);

    return _db.put(id.value, user);
  }

  @override
  List<SuperAdmin> get superAdmins {
    final users = _db.getAll();

    return users
        .where((user) => user.role is SuperAdmin)
        .cast<SuperAdmin>()
        .toList();
  }

  @override
  void updateEmail(Id id, Email newEmail) {
    final user = _db.get(id.value);
    if (user != null) {
      final updated = User(
        id: user.id,
        email: newEmail,
        role: user.role,
        password: user.password,
      );
      _db.put(id.value, updated);
    }
  }

  @override
  void updatePassword(Id id, Password newPassword) {
    final user = _db.get(id.value);
    if (user != null) {
      final updated = User(
        id: user.id,
        email: user.email,
        role: user.role,
        password: newPassword,
      );
      _db.put(id.value, updated);
    }
  }

  @override
  List<User> get users => _db.getAll();

  @override
  void delete(Id id) {
    _db.delete(id.value);
  }
}
