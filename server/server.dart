import 'package:get_it/get_it.dart';

import '../db/in_memory_db.dart';
import 'domain/entities/user.dart';
import 'infrastructure/repositories/in_memory_user_repository.dart';
import 'router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'infrastructure/middlewares/jwt.dart';

void main() async {
final getIt = GetIt.instance;
getIt.registerSingleton<InMemoryUserRepository>(InMemoryUserRepository(InMemoryDb<User>()));

  final pipeline = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(jwtMiddleware)
      .addHandler(router);

  final server = await shelf_io.serve(pipeline, 'localhost', 8080);
  server.autoCompress = true;
  print('Serving at http://${server.address.host}:${server.port}');
}
