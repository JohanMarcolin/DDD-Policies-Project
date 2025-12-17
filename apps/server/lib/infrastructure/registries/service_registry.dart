import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:server/infrastructure/registries/database_registry.dart';
import 'package:server/infrastructure/registries/policy_registry.dart';
import 'package:server/infrastructure/registries/repository_registry.dart';
import 'package:server/infrastructure/security/token_service.dart';
import 'package:server/infrastructure/services/auth_service.dart';
import 'package:server/infrastructure/services/test_service.dart';
import 'package:server/infrastructure/services/user_service.dart';

/// A registry for accessing service instances used in the application.
class ServiceRegistry {
  static final authService = AuthService(
    userRepository: RepositoryRegistry.userRepository,
    tokenService: tokenService,
    userPasswordDatabase: DatabaseRegistry.userPasswordDatabase,
  );
  static final testService = TestService(
    userDatabase: DatabaseRegistry.userDatabase,
    userPasswordDatabase: DatabaseRegistry.userPasswordDatabase,
    passwordValidationPolicy: PolicyRegistry.userPasswordValidationPolicy,
  );
  static final tokenService = TokenService(
    refreshTokenDatabase: DatabaseRegistry.refreshTokenDatabase,
  );
  static final userAdministrationService = UserAdministrationService(
    userRepository: RepositoryRegistry.userRepository,
    viewUserPolicy: PolicyRegistry.viewUserPolicy,
    updateUserEmailPolicy: PolicyRegistry.updateUserEmailPolicy,
    updateUserPasswordPolicy: PolicyRegistry.updateUserPasswordPolicy,
    deleteUserPolicy: PolicyRegistry.deleteUserPolicy,
    userEmailValidationPolicy: PolicyRegistry.userEmailValidationPolicy,
    userPasswordValidationPolicy: PolicyRegistry.userPasswordValidationPolicy,
  );
  static final userService = UserService(
    userRepository: RepositoryRegistry.userRepository,
    userAdministrationService: userAdministrationService,
  );
}
