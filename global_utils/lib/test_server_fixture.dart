import 'dart:io';

import 'package:server/infrastructure/server.dart';

class TestServerFixture {
  static Server? _server;
  static HttpServer? _httpServer;

  static Future<void> start({bool enableTestRoutes = false, bool setupTestUsers = false}) async {
    final randomPort = 0;
    _server = Server(port: randomPort, enableTestRoutes: enableTestRoutes, setupTestUsers: setupTestUsers);
    _httpServer = await _server!.start();
  }

  static Future<void> stop() async {
    await _server?.stop();
    _httpServer = null;
    _server = null;
  }

  static String get baseUrl {
    if (_httpServer == null) throw StateError('Test server not started');
    return 'http://localhost:${_httpServer!.port}';
  }
}
