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
  User? get({required UserId userId}) => _users.where((u) => u.userId == userId).firstOrNull;

  @override
  User? getByEmail({required Email email}) =>
      _users.where((u) => u.email == email).firstOrNull;

  @override
  void delete({required UserId userId}) => _users.removeWhere((u) => u.userId == userId);

  @override
  void updateEmail({required UserId userId, required Email newEmail}) {
    final user = get(userId: userId);
    if (user != null) {
      final updated = User(userId: user.userId, email: newEmail, role: user.role);
      final index = _users.indexWhere((u) => u.userId == userId);
      if (index != -1) _users[index] = updated;
    }
  }

  @override
  void updatePassword({required UserId userId, required Password newPassword}) {
    final user = get(userId: userId);
    if (user != null) {
      final updated = User(userId: user.userId, email: user.email, role: user.role);
      final index = _users.indexWhere((u) => u.userId == userId);
      if (index != -1) _users[index] = updated;
    }
  }
}