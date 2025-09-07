import '../databases/database.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/value_objects/email.dart';
import '../../domain/value_objects/id.dart';
import '../../domain/value_objects/password.dart';

class InMemoryUserRepository implements UserRepository {
  InMemoryUserRepository(Database<User> db) : _db = db {}

  final Database<User> _db;

  @override
  User? get({required Id id}) {
    return _db.get(id);
  }

  @override
  User? getByEmail({required Email email}) {
    final users = _db.getAll();

    return users.firstWhere((user) => user.email.value == email.value);
  }

  @override
  void updateEmail({required Id id, required Email newEmail}) {
    final user = _db.get(id);
    if (user != null) {
      final updated = User(
        id: user.id,
        email: newEmail,
        role: user.role,
      );
      _db.put(id, updated);
    }
  }

  @override
  void updatePassword({required Id id, required Password newPassword}) {
    final user = _db.get(id);
    if (user != null) {
      final updated = User(
        id: user.id,
        email: user.email,
        role: user.role,
      );
      _db.put(id, updated);
    }
  }

  @override
  List<User> get users => _db.getAll();

  @override
  void delete({required Id id}) {
    _db.delete(id);
  }
}
