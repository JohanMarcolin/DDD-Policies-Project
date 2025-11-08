import 'package:domain/value_objects/id.dart';
import 'database.dart';

typedef RefreshToken = String;

class RefreshTokenDatabase implements Database<RefreshToken> {
  RefreshTokenDatabase();

  final Map<Id, RefreshToken> _tokens = {};

  @override
  RefreshToken? get(Id id) => _tokens[id];

  @override
  List<RefreshToken> getAll() => _tokens.values.toList();

  @override
  void put(Id id, RefreshToken value) {
    _tokens[id] = value;
  }

  @override
  void delete(Id id) {
    _tokens.remove(id);
  }
}
