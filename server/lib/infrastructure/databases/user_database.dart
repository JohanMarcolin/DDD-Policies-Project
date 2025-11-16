import 'package:domain/entities/user.dart';
import 'package:domain/value_objects/id.dart';
import 'database.dart';

class UserDatabase implements Database<User> {
  UserDatabase();

  final Map<Id, User> _users = {};

  @override
  Future<User?> get(Id id) async => _users[id];

  @override
  Future<List<User>> getAll() async => _users.values.toList();

  @override
  Future<void> put(Id id, User value) async => _users[id] = value;

  @override
  Future<void> delete(Id id) async => _users.remove(id);
}
