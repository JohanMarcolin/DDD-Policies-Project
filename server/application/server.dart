import 'package:get_it/get_it.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../domain/operations/operation.dart';
import '../../domain/policies/policy.dart';
import '../../domain/services/user_administration/user_administration_service.dart';
import '../infrastructure/databases/user_password_database.dart';
import '../infrastructure/factories/mock_user_factory.dart';
import '../infrastructure/repositories/in_memory_user_repository.dart';
import '../infrastructure/security/password_hasher.dart';
import '../infrastructure/route_providers/auth_route_provider.dart';
import '../infrastructure/services/auth_service.dart';
import '../infrastructure/databases/refresh_token_database.dart';
import '../infrastructure/databases/user_database.dart';
import '../infrastructure/security/token_service.dart';
import '../infrastructure/route_providers/user_route_provider.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import '../infrastructure/security/security_filter_chain.dart';

final getIt = GetIt.instance;

void main() async {
  final router = getIt.registerSingleton<Router>(Router());

  final userDatabase = getIt.registerSingleton<UserDatabase>(UserDatabase());

  final passwordHasher =
      getIt.registerSingleton<PasswordHasher>(PasswordHasher());

  final userPasswordDatabase = getIt.registerSingleton<UserPasswordDatabase>(
      UserPasswordDatabase(passwordHasher: passwordHasher));

  final inMemoryUserRepository =
      getIt.registerSingleton<InMemoryUserRepository>(InMemoryUserRepository(
          userDatabase: userDatabase,
          userPasswordDatabase: userPasswordDatabase));

  final refreshTokenDatabase =
      getIt.registerSingleton<RefreshTokenDatabase>(RefreshTokenDatabase());

  final tokenService = getIt.registerSingleton<TokenService>(
      TokenService(refreshTokenDatabase: refreshTokenDatabase));

  final securityFilterChain = getIt.registerSingleton<SecurityFilterChain>(
      SecurityFilterChain(tokenService: tokenService));

  final authService = getIt.registerSingleton<AuthService>(AuthService(
      userRepository: inMemoryUserRepository, tokenService: tokenService));

  final viewUsersOperation =
      getIt.registerSingleton<ViewUsersOperation>(ViewUsersOperation());

  final viewUserPolicy =
      getIt.registerSingleton<ViewUserPolicy>(ViewUserPolicy());
  final updateUserEmailPolicy =
      getIt.registerSingleton<UpdateUserEmailPolicy>(UpdateUserEmailPolicy());
  final updateUserPasswordPolicy = getIt
      .registerSingleton<UpdateUserPasswordPolicy>(UpdateUserPasswordPolicy());
  final deleteUserPolicy =
      getIt.registerSingleton<DeleteUserPolicy>(DeleteUserPolicy());

  final userAdministrationService = getIt
      .registerSingleton<UserAdministrationService>(UserAdministrationService(
          userRepository: inMemoryUserRepository,
          viewUsersOperation: viewUsersOperation,
          viewUserPolicy: viewUserPolicy,
          updateUserEmailPolicy: updateUserEmailPolicy,
          updateUserPasswordPolicy: updateUserPasswordPolicy,
          deleteUserPolicy: deleteUserPolicy));

  final authRouteProvider = getIt.registerSingleton<AuthRouteProvider>(
      AuthRouteProvider(authService: authService));
  final userRouteProvider = getIt.registerSingleton<UserRouteProvider>(
      UserRouteProvider(userAdministrationService: userAdministrationService));

  authRouteProvider.appendRoutes(router);
  userRouteProvider.appendRoutes(router);

  final pipeline = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(securityFilterChain.middleware)
      .addHandler(router);

  _setupMockUsers(
    userDatabase: userDatabase,
    userPasswordDatabase: userPasswordDatabase,
  );

  final server = await shelf_io.serve(pipeline, 'localhost', 8080);
  server.autoCompress = true;
  print('Serving at http://${server.address.host}:${server.port}');
}

void _setupMockUsers({
  required UserDatabase userDatabase,
  required UserPasswordDatabase userPasswordDatabase,
}) {
  for (final entry in MockUserFactory.createDefaultUsersWithPasswords()) {
    final user = entry.keys.first;
    final password = entry.values.first;

    userDatabase.put(user.id, user);
    userPasswordDatabase.put(user.id, password);
  }
}
