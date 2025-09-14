import '../../../domain/entities/user.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../domain/value_objects/email.dart';
import '../../../domain/value_objects/id.dart';
import '../../../domain/value_objects/password.dart';

class DummyUserRepository implements UserRepository {
  DummyUserRepository(List<User> users) : _users = users;

  final List<User> _users;

  @override
  List<User> get users => _users;

  @override
  User? get({required Id id}) => _users.where((u) => u.id == id).firstOrNull;

  @override
  User? getByEmail({required Email email}) =>
      _users.where((u) => u.email == email).firstOrNull;

  @override
  void delete({required Id id}) => _users.removeWhere((u) => u.id == id);

  @override
  void updateEmail({required Id id, required Email newEmail}) {
    final user = get(id: id);
    if (user != null) {
      final updated = User(id: user.id, email: newEmail, role: user.role);
      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1) _users[index] = updated;
    }
  }

  @override
  void updatePassword({required Id id, required Password newPassword}) {
    final user = get(id: id);
    if (user != null) {
      final updated = User(id: user.id, email: user.email, role: user.role);
      final index = _users.indexWhere((u) => u.id == id);
      if (index != -1) _users[index] = updated;
    }
  }
}