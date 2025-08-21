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
  InMemoryUserRepository(InMemoryDb<User> db) : _db = db;

  final InMemoryDb<User> _db;

  @override
  List<Admin> get admins {
    final users = _db.getAll();

    return users.where((user) => user.isAdmin).cast<Admin>().toList();
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
        .where((user) => user.role == Role.superAdmin)
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
        password: user.password, // preserve password
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
