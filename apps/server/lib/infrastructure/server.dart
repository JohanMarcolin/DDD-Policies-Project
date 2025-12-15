import 'dart:io';
import 'package:domain/entities/user.dart';
import 'package:domain/repositories/user_repository.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/password.dart';
import 'package:domain/value_objects/role.dart';
import 'package:server/infrastructure/policy_registry.dart';
import 'package:test_utils/fixtures/user/user_test_fixture.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:domain/services/user_administration/user_administration_service.dart';
import 'controllers/test_controller.dart';
import 'databases/in_memory_user_password_database.dart';
import 'http/global_exception_handler.dart';
import 'repositories/in_memory_user_repository.dart';
import 'security/password_hasher.dart';
import 'controllers/auth_controller.dart';
import 'services/auth_service.dart';
import 'databases/in_memory_refresh_token_database.dart';
import 'databases/in_memory_user_database.dart';
import 'security/token_service.dart';
import 'controllers/user_controller.dart';
import 'security/security_filter_chain.dart';
import 'services/test_service.dart';
import 'services/user_service.dart';
import 'package:env_config/env_config.dart';

/// Shelf-based HTTP server.
///
/// Manages routing, middleware, controller setup, and optionally seeds development/test users.
///
/// - Set [exposeTestRoutes] to true to enable internal test endpoints for development and integration testing.
/// - Set [seedDevelopmentUsers] to true to populate the database with predefined test users for local development and manual testing.
class Server {
  Server({String? host, int? port, this.exposeTestRoutes = false, this.seedDevelopmentUsers = false})
      : host = host ?? Env.serverHost,
        port = port ?? Env.serverPort;
  final String host;
  final int port;
  final bool exposeTestRoutes;
  final bool seedDevelopmentUsers;
  late final String baseUrl;
  
  HttpServer? _server;

  /// Starts the server, configures all routes, middleware, and optionally seeds test users.
  ///
  /// Returns the running [HttpServer] instance.
  Future<HttpServer> start() async {
    final router = Router();
    final userDatabase = InMemoryUserDatabase();
    final passwordHasher = PasswordHasher();
    final userPasswordDatabase = InMemoryUserPasswordDatabase(passwordHasher: passwordHasher);
    final inMemoryUserRepository = InMemoryUserRepository(
      userDatabase: userDatabase,
      userPasswordDatabase: userPasswordDatabase,
    );
    final refreshTokenDatabase = InMemoryRefreshTokenDatabase();
    final tokenService = TokenService(refreshTokenDatabase: refreshTokenDatabase);
    final securityFilterChain = SecurityFilterChain(tokenService: tokenService);

    _setupControllers(
        router: router,
        userRepository: inMemoryUserRepository,
        userPasswordDatabase: userPasswordDatabase,
        tokenService: tokenService);

    if (exposeTestRoutes) {
      final testService = TestService(
          userDatabase: userDatabase,
          userPasswordDatabase: userPasswordDatabase,
          passwordValidationPolicy: PolicyRegistry.userPasswordValidationPolicy);
      final testController = TestController(testService: testService);
      router.mount('/test/', testController.handler);
    }

    if (seedDevelopmentUsers) {
      final fixtures = _setupDevelopmentUserFixtures();
      for (final fixture in fixtures) {
        await userDatabase.put(fixture.user.userId, fixture.user);
        await userPasswordDatabase.put(fixture.user.userId, fixture.password);
      }
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

  /// Stops the running server and releases all resources.
  ///
  /// After calling this, the server instance cannot be reused until [start] is called again.
  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }
}

/// Configures and mounts all controllers and their routes on the [router].
///
/// [userRepository] and [tokenService] are injected dependencies for controller/service construction.
void _setupControllers(
    {required Router router,
    required UserRepository userRepository,
    required InMemoryUserPasswordDatabase userPasswordDatabase,
    required TokenService tokenService}) {
  final authService = AuthService(
    userRepository: userRepository,
    userPasswordDatabase: userPasswordDatabase,
    tokenService: tokenService,
  );
  final userAdministrationService = UserAdministrationService(
    userRepository: userRepository,
    viewUserPolicy: PolicyRegistry.viewUserPolicy,
    updateUserEmailPolicy: PolicyRegistry.updateUserEmailPolicy,
    updateUserPasswordPolicy: PolicyRegistry.updateUserPasswordPolicy,
    deleteUserPolicy: PolicyRegistry.deleteUserPolicy,
    userEmailValidationPolicy: PolicyRegistry.userEmailValidationPolicy,
    userPasswordValidationPolicy: PolicyRegistry.userPasswordValidationPolicy,
  );
  final userService = UserService(
    userRepository: userRepository,
    userAdministrationService: userAdministrationService,
  );
  final authController = AuthController(authService: authService);
  final userController = UserController(userService: userService);
  router.mount('/auth/', authController.handler);
  router.mount('/user/', userController.handler);
}

/// Generates a list of [UserTestFixture] for development/test seeding.
List<UserTestFixture> _setupDevelopmentUserFixtures() {
  final fixtureCredentials = [
    {'email': 'user1', 'password': 'user1', 'role': Role.user},
    {'email': 'user2', 'password': 'user2', 'role': Role.user},
    {'email': 'admin1', 'password': 'admin1', 'role': Role.admin},
    {'email': 'admin2', 'password': 'admin2', 'role': Role.admin},
    {'email': 'analyst1', 'password': 'analyst1', 'role': Role.analyst},
    {'email': 'analyst2', 'password': 'analyst2', 'role': Role.analyst},
  ];
  final fixtures = <UserTestFixture>[];
  for (var credentials in fixtureCredentials) {
    final user = User(
      userId: UserId.generate(),
      email: Email(credentials['email'] as String),
      role: credentials['role'] as Role,
    );
    final password = Password(credentials['password'] as String);
    final userFixture = UserTestFixture(user: user, password: password);
    fixtures.add(userFixture);
  }
  return fixtures;
}
