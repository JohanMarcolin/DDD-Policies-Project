import 'package:domain/value_objects/id.dart';
import 'package:server/infrastructure/security/token_service.dart';

import 'in_memory_database.dart';

/// Provides an in-memory database for refresh tokens associated with user/session [Id]s.
final class InMemoryRefreshTokenDatabase extends InMemoryDatabase<Id, RefreshToken> {}
