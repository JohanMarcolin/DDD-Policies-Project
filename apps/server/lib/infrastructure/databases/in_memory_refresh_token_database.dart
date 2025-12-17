import 'package:domain/value_objects/id.dart';
import 'package:server/infrastructure/security/token_service.dart';

import 'in_memory_database.dart';

/// Provides an in-memory database for [RefreshToken] associated with [UserId]s.
final class InMemoryRefreshTokenDatabase extends InMemoryDatabase<UserId, RefreshToken> {}
