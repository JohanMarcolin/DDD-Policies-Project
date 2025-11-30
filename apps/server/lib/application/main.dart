import '../infrastructure/server.dart';

void main() async {
  final server = Server(seedDevelopmentUsers: true);
  await server.start();
}
