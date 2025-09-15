import 'dart:io';

import '../../../server/infrastructure/factories/server_factory.dart';

class TestServerFactory {
  static ServerFactory? _serverFactory;
  static HttpServer? _server;

  static Future<void> start() async {
    final randomPort = 0;
    _serverFactory = ServerFactory(port: randomPort, isTest: true);
    _server = await _serverFactory!.start();
  }

  static Future<void> stop() async {
    await _serverFactory?.stop();
    _server = null;
    _serverFactory = null;
  }

  static String get baseUrl {
    if (_server == null) throw StateError('Test server not started');
    return 'http://localhost:${_server!.port}';
  }
}
