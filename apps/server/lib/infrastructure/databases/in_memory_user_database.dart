import 'package:domain/entities/user.dart';
import 'package:domain/value_objects/id.dart';
import 'in_memory_database.dart';

/// Provides an in-memory database for [User] entities associated with [UserId]s.
final class InMemoryUserDatabase extends InMemoryDatabase<UserId, User> {}
