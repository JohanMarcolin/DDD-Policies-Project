import 'package:env_config/env_config.dart';

import '../infrastructure/server.dart';

/// Entry point for the server application.
///
/// Initializes and starts the [Server].
void main() async {
  final server = Server(seedTestUsers: Env.serverShouldSeedTestUsers);
  await server.start();
}
