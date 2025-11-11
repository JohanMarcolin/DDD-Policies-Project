import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:domain/services/user_administration/user_administration_service.dart';
import '../../../test/utils/factories/test_user_entry_factory.dart';
import '../controllers/test_controller.dart';
import '../databases/user_password_database.dart';
import '../http/global_exception_handler.dart';
import '../repositories/in_memory_user_repository.dart';
import '../security/password_hasher.dart';
import '../controllers/auth_controller.dart';
import '../services/auth_service.dart';
import '../databases/refresh_token_database.dart';
import '../databases/user_database.dart';
import '../security/token_service.dart';
import '../controllers/user_controller.dart';
import '../security/security_filter_chain.dart';
import '../services/test_service.dart';
import '../services/user_service.dart';

class ServerFactory {
  ServerFactory(
      {this.host = '0.0.0.0',
      required this.port,
      this.enableTestRoutes = false,
      this.includeDefaultUsers = false});
  final String host;
  final int port;
  final bool enableTestRoutes;
  final bool includeDefaultUsers;
  HttpServer? _server;
  late String baseUrl;

  Future<HttpServer> start() async {
    final router = Router();
    final userDatabase = UserDatabase();
    final passwordHasher = PasswordHasher();
    final userPasswordDatabase =
        UserPasswordDatabase(passwordHasher: passwordHasher);
    final inMemoryUserRepository = InMemoryUserRepository(
      userDatabase: userDatabase,
      userPasswordDatabase: userPasswordDatabase,
    );
    final refreshTokenDatabase = RefreshTokenDatabase();
    final tokenService =
        TokenService(refreshTokenDatabase: refreshTokenDatabase);
    final securityFilterChain = SecurityFilterChain(tokenService: tokenService);
    final authService = AuthService(
      userRepository: inMemoryUserRepository,
      tokenService: tokenService,
    );
    final viewUserPolicy = ViewUserPolicy();
    final updateUserEmailPolicy = UpdateUserEmailPolicy();
    final updateUserPasswordPolicy = UpdateUserPasswordPolicy();
    final deleteUserPolicy = DeleteUserPolicy();

    final emailValidationPolicy = EmailValidationPolicy();
    final passwordValidationPolicy = PasswordValidationPolicy();

    final userAdministrationService = UserAdministrationService(
      userRepository: inMemoryUserRepository,
      viewUserPolicy: viewUserPolicy,
      updateUserEmailPolicy: updateUserEmailPolicy,
      updateUserPasswordPolicy: updateUserPasswordPolicy,
      deleteUserPolicy: deleteUserPolicy,
      emailValidationPolicy: emailValidationPolicy,
      passwordValidationPolicy: passwordValidationPolicy,
    );

    final userService = UserService(
        userRepository: inMemoryUserRepository,
        userAdministrationService: userAdministrationService);

    final authController = AuthController(authService: authService);
    final userController = UserController(userService: userService);

    router.mount('/auth/', authController.handler);
    router.mount('/user/', userController.handler);

    if (enableTestRoutes) {
      final testService = TestService(
        userDatabase: userDatabase,
        userPasswordDatabase: userPasswordDatabase,
      );

      final testController = TestController(
        testService: testService,
      );

      router.mount('/test/', testController.handler);
    }

    if (includeDefaultUsers) {
      UserTestFixtureFactory.setupDefaultUsers(
        userDatabase: userDatabase,
        userPasswordDatabase: userPasswordDatabase,
      );
    }

    final pipeline = const Pipeline()
        .addMiddleware(globalExceptionHandler())
        .addMiddleware(logRequests())
        .addMiddleware(securityFilterChain.middleware)
        .addHandler(router.call);

    final server = await shelf_io.serve(pipeline, host, port);
    server.autoCompress = true;
    baseUrl = 'http://${server.address.host}:${server.port}';
    print('Serving at $baseUrl');
    _server = server;
    return server;
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }
}
