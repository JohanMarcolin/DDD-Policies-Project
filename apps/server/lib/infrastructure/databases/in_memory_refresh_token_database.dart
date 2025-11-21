import 'package:domain/value_objects/id.dart';
import 'package:server/infrastructure/security/token_service.dart';
import 'in_memory_database.dart';

/// Provides an in-memory database for refresh tokens associated with user/session [Id]s.
class InMemoryRefreshTokenDatabase implements InMemoryDatabase<Id, RefreshToken> {
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
