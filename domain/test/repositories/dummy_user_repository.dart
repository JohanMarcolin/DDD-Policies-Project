import 'package:domain/entities/user.dart';
import 'package:domain/repositories/user_repository.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/password.dart';

class DummyUserRepository implements UserRepository {
  DummyUserRepository(List<User> users) : _users = users;

  final List<User> _users;

  @override
  Future<List<User>> get users async => _users;

  @override
  Future<User?> get({required UserId userId}) async => _users.where((u) => u.userId == userId).firstOrNull;

  @override
  Future<User?> getByEmail({required Email email}) async => _users.where((u) => u.email == email).firstOrNull;

  @override
  Future<void> delete({required UserId userId}) async {
    _users.removeWhere((u) => u.userId == userId);
  }

  @override
  Future<void> updateEmail({required UserId userId, required Email newEmail}) async {
    final user = await get(userId: userId);
    if (user != null) {
      final updated = User(userId: user.userId, email: newEmail, role: user.role);
      final index = _users.indexWhere((u) => u.userId == userId);
      if (index != -1) _users[index] = updated;
    }
  }

  @override
  Future<void> updatePassword({required UserId userId, required Password newPassword}) async {
    final user = await get(userId: userId);
    if (user != null) {
      final updated = User(userId: user.userId, email: user.email, role: user.role);
      final index = _users.indexWhere((u) => u.userId == userId);
      if (index != -1) _users[index] = updated;
    }
  }
}
