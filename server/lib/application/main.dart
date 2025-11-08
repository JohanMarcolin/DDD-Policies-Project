import '../../infrastructure/factories/server_factory.dart';

void main() async {
  final serverFactory = ServerFactory(port: 8080, includeDefaultUsers: true);
  await serverFactory.start();
}
