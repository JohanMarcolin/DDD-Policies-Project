import 'dart:io';

import '../infrastructure/server.dart';

void main() async {
  final server = Server(seedDevelopmentUsers: true);
  await server.start();

  ProcessSignal.sigint.watch().listen((_) async {
    await server.stop();
  });
}
