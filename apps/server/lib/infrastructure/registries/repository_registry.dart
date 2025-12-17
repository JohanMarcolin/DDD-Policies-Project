import 'package:server/infrastructure/registries/database_registry.dart';
import 'package:server/infrastructure/repositories/in_memory_user_repository.dart';

/// A registry for accessing repository instances used in the application.
class RepositoryRegistry {
  static final userRepository = InMemoryUserRepository(
      userDatabase: DatabaseRegistry.userDatabase, userPasswordDatabase: DatabaseRegistry.userPasswordDatabase);
}
