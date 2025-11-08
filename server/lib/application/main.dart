import '../../infrastructure/factories/server_factory.dart';
void main() async {
  final serverFactory = ServerFactory(port: 8080, isTest: true);
  await serverFactory.start();
}
