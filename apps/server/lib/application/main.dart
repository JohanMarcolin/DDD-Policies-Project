import '../infrastructure/server.dart';

/// Entry point for the server application.
///
/// Initializes and starts the [Server].
void main() async {
  final server = Server(seedDevelopmentUsers: true);
  await server.start();
}
