import 'package:env_config/env_config.dart';

import '../infrastructure/server.dart';

/// Entry point for the server application.
///
/// Initializes and starts the [Server].
void main() async {
  final shouldSeedTestUsers = Env.serverShouldSeedTestUsers == 'true';
  final server = Server(seedTestUsers: shouldSeedTestUsers);
  await server.start();
}
