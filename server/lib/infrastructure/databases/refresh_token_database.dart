import 'package:domain/value_objects/id.dart';
import 'database.dart';

typedef RefreshToken = String;

class RefreshTokenDatabase implements Database<RefreshToken> {
  RefreshTokenDatabase();

  final Map<Id, RefreshToken> _tokens = {};

  @override
  Future<RefreshToken?> get(Id id) async => _tokens[id];

  @override
  Future<List<RefreshToken>> getAll() async => _tokens.values.toList();

  @override
  Future<void> put(Id id, RefreshToken value) async => _tokens[id] = value;

  @override
  Future<void> delete(Id id) async => _tokens.remove(id);
}
