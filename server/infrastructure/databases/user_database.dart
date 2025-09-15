import '../../../domain/entities/user.dart';
import '../../../domain/value_objects/id.dart';
import 'database.dart';

class UserDatabase implements Database<User> {
  UserDatabase();

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
