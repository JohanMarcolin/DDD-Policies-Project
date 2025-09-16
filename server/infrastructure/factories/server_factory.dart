import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import '../../../domain/policies/action_policies/action_policy.dart';
import '../../../domain/policies/validation_policies/validation_policy.dart';
import '../../../domain/services/user_administration/user_administration_service.dart';
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
import '../../../test/utils/factories/test_user_entry_factory.dart';

class ServerFactory {
  ServerFactory(
      {this.host = '0.0.0.0', required this.port, this.isTest = false});
  final String host;
  final int port;
  final bool isTest;
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
    final authController = AuthController(authService: authService);
    final userController =
        UserController(userAdministrationService: userAdministrationService);

    router.mount('/auth/', authController.handler);
    router.mount('/user/', userController.handler);

    if (isTest) {
      TestUserEntryFactory.setupDefaultUsers(
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
