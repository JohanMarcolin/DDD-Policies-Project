import 'package:server/infrastructure/databases/in_memory_refresh_token_database.dart';
import 'package:server/infrastructure/databases/in_memory_user_database.dart';
import 'package:server/infrastructure/databases/in_memory_user_password_database.dart';
import 'package:server/infrastructure/security/password_hasher.dart';

/// A registry for accessing database instances used in the application.
class DatabaseRegistry {
  static final refreshTokenDatabase = InMemoryRefreshTokenDatabase();
  static final userDatabase = InMemoryUserDatabase();
  static final userPasswordDatabase = InMemoryUserPasswordDatabase(passwordHasher: PasswordHasher());
}
