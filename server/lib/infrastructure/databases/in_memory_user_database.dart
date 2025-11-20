import 'package:domain/entities/user.dart';
import 'package:domain/value_objects/id.dart';
import 'in_memory_database.dart';

/// Provides an in-memory database for [User] entities associated with [UserId]s.
class InMemoryUserDatabase implements InMemoryDatabase<UserId, User> {
  final Map<UserId, User> _users = {};

  @override
  Future<User?> get(UserId id) async => _users[id];

  @override
  Future<List<User>> getAll() async => _users.values.toList();

  @override
  Future<void> put(UserId id, User value) async => _users[id] = value;

  @override
  Future<void> delete(UserId id) async => _users.remove(id);
}
