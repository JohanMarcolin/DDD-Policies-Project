import 'dart:io';
import 'package:server/infrastructure/server.dart';

/// Utility class for managing a http server instance for testing purposes.
class TestServerFixture {
  static Server? _server;
  static HttpServer? _httpServer;

  /// Starts the test server with optional test routes and user seeding.
  static Future<void> start({bool exposeTestRoutes = false, bool seedTestUsers = false}) async {
    final randomPort = 0;
    _server = Server(port: randomPort, exposeTestRoutes: exposeTestRoutes, seedTestUsers: seedTestUsers);
    _httpServer = await _server!.start();
  }

  /// Stops the test server and cleans up resources.
  static Future<void> stop() async {
    await _server?.stop();
    _httpServer = null;
    _server = null;
  }

  /// Returns the base url of the running test server.
  ///
  /// Throws [StateError] if the server was not yet started.
  static String get baseUrl {
    if (_httpServer == null) throw StateError('Test server not started');
    return 'http://localhost:${_httpServer!.port}';
  }
}
