import 'dart:io';

class TestServerFactory {
  static int port = 8081;
  static String host = 'localhost';
  static Process? _process;

  static String get baseUrl => 'http://$host:$port';

  static Future<void> start() async {
    _process = await Process.start(
      'dart',
      ['run', 'server/application/main.dart', '$port', host],
      mode: ProcessStartMode.detached,
    );
    await _waitForPortOpen();
  }

  static Future<void> stop() async {
    _process?.kill();
  }

  /// Waits until the server port is open and accepting connections.
  /// Throws if the server is not ready after [maxAttempts] tries.
  static Future<void> _waitForPortOpen(
      {int maxAttempts = 10,
      Duration delay = const Duration(milliseconds: 100)}) async {
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final socket = await Socket.connect(host, port, timeout: delay);
        socket.destroy();
        return;
      } catch (_) {}
      await Future.delayed(delay);
    }
    throw Exception(
        'Test server did not open port $port on $host after $maxAttempts attempts');
  }
}
