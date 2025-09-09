import 'package:get_it/get_it.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../domain/policies/policy.dart';
import '../../domain/services/user_administration/user_administration_service.dart';
import '../infrastructure/databases/user_password_database.dart';
import '../infrastructure/factories/mock_user_factory.dart';
import '../infrastructure/http/global_exception_handler.dart';
import '../infrastructure/repositories/in_memory_user_repository.dart';
import '../infrastructure/security/password_hasher.dart';
import '../infrastructure/controllers/auth_controller.dart';
import '../infrastructure/services/auth_service.dart';
import '../infrastructure/databases/refresh_token_database.dart';
import '../infrastructure/databases/user_database.dart';
import '../infrastructure/security/token_service.dart';
import '../infrastructure/controllers/user_controller.dart';
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
          viewUserPolicy: viewUserPolicy,
          updateUserEmailPolicy: updateUserEmailPolicy,
          updateUserPasswordPolicy: updateUserPasswordPolicy,
          deleteUserPolicy: deleteUserPolicy));

  final authController = getIt.registerSingleton<AuthController>(
      AuthController(authService: authService));
  final userController = getIt.registerSingleton<UserController>(
      UserController(userAdministrationService: userAdministrationService));

  router.mount('/auth/', authController.handler);
  router.mount('/user/', userController.handler);

  final pipeline = const Pipeline()
      .addMiddleware(globalExceptionHandler())
      .addMiddleware(logRequests())
      .addMiddleware(securityFilterChain.middleware)
      .addHandler(router);

  MockUserFactory.setupDefaultUsers(
    userDatabase: userDatabase,
    userPasswordDatabase: userPasswordDatabase,
  );

  final server = await shelf_io.serve(pipeline, 'localhost', 8080);
  server.autoCompress = true;
  print('Serving at http://${server.address.host}:${server.port}');
}
