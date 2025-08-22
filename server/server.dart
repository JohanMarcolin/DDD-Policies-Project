import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:get_it/get_it.dart';

import '../db/in_memory_db.dart';
import 'domain/entities/user.dart';
import 'infrastructure/authentication/login_service.dart';
import 'infrastructure/repositories/in_memory_user_repository.dart';
import 'infrastructure/security/token_service.dart';
import 'router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'infrastructure/security/security_filter_chain.dart';

void main() async {
final getIt = GetIt.instance;

getIt.registerSingleton<InMemoryUserRepository>(InMemoryUserRepository(InMemoryDb<User>()));
getIt.registerSingleton<TokenService>(TokenService(SecretKey('your-secret-key')));
getIt.registerSingleton<SecurityFilterChain>(SecurityFilterChain(getIt<TokenService>()));
getIt.registerSingleton<LoginService>(LoginService(getIt<InMemoryUserRepository>()));
getIt.registerSingleton<RouterProvider>(RouterProvider(getIt<LoginService>()));

  final pipeline = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(getIt<SecurityFilterChain>().middleware)
      .addHandler(getIt<RouterProvider>().handler);

  final server = await shelf_io.serve(pipeline, 'localhost', 8080);
  server.autoCompress = true;
  print('Serving at http://${server.address.host}:${server.port}');
}
