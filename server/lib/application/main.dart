import '../infrastructure/server.dart';

void main() async {
  final serverFactory = Server(port: 8080);
  await serverFactory.start();
}
