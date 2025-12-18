import 'dart:io';
import 'package:env_config/env_config.dart';
import 'package:server/infrastructure/controllers/auth_controller.dart';
import 'package:server/infrastructure/controllers/test_controller.dart';
import 'package:server/infrastructure/controllers/user_controller.dart';
import 'package:server/infrastructure/http/global_exception_handler/global_exception_handler.dart';

import 'package:server/infrastructure/registries/database_registry.dart';
import 'package:server/infrastructure/registries/service_registry.dart';
import 'package:server/infrastructure/security/security_filter_chain.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

/// Shelf-based http server.
///
/// Manages routing, middleware, controller setup, and optionally seeds test users.
///
/// - Set [exposeTestRoutes] to `true` to enable test endpoints for api and integration testing.
/// - Set [seedTestUsers] to `true` to populate the database with default test users for development and testing purposes.
class Server {
  Server({String? host, int? port, this.exposeTestRoutes = false, this.seedTestUsers = false})
      : host = host ?? Env.serverHost,
        port = port ?? Env.serverPort;
  final String host;
  final int port;
  final bool exposeTestRoutes;
  final bool seedTestUsers;

  HttpServer? _server;

  /// Starts the server, configures all routes, middleware, and optionally seeds test users.
  ///
  /// Returns the running [HttpServer] instance.
  Future<HttpServer> start() async {
    final router = Router();

    _mountControllers(router: router, shouldMountTestController: exposeTestRoutes);

    if (seedTestUsers) await _seedTestUsers();

    final pipeline = _configurePipeline(router);

    final server = await shelf_io.serve(pipeline, host, port);
    server.autoCompress = true;
    print('Serving at http://${server.address.host}:${server.port}');
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

  /// Configures and mounts all controllers and their routes on the [router].
  void _mountControllers({required Router router, required bool shouldMountTestController}) {
    final authController = AuthController(authService: ServiceRegistry.authService);
    router.mount('/auth/', authController.handler);

    final userController = UserController(userService: ServiceRegistry.userService);
    router.mount('/user/', userController.handler);

    if (shouldMountTestController) {
      final testController = TestController(testService: ServiceRegistry.testService);
      router.mount('/test/', testController.handler);
    }
  }

  /// Configures the middleware pipeline for the server.
  Handler _configurePipeline(Router router) {
    final securityFilterChain = SecurityFilterChain(tokenService: ServiceRegistry.tokenService);

    return const Pipeline()
        .addMiddleware(globalExceptionHandler())
        .addMiddleware(logRequests())
        .addMiddleware(securityFilterChain.middleware)
        .addHandler(router.call);
  }

  /// Seeds test users into the database for development and testing.
  Future<void> _seedTestUsers() async {
    for (final fixture in ServiceRegistry.testService.generateDefaultUserFixtures()) {
      await DatabaseRegistry.userDatabase.put(fixture.user.userId, fixture.user);
      await DatabaseRegistry.userPasswordDatabase.put(fixture.user.userId, fixture.password);
    }
  }
}
