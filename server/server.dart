import 'package:get_it/get_it.dart';

import 'infrastructure/authentication/auth_service.dart';
import 'infrastructure/databases/refresh_token_database.dart';
import 'infrastructure/databases/user_database.dart';
import 'infrastructure/repositories/in_memory_user_repository.dart';
import 'infrastructure/security/token_service.dart';
import 'router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'infrastructure/security/security_filter_chain.dart';

void main() async {
  final getIt = GetIt.instance;

  getIt.registerSingleton<UserDatabase>(UserDatabase());
  getIt.registerSingleton<InMemoryUserRepository>(
      InMemoryUserRepository(getIt<UserDatabase>()));
  getIt.registerSingleton<RefreshTokenDatabase>(RefreshTokenDatabase());
  getIt.registerSingleton<TokenService>(
      TokenService(getIt<RefreshTokenDatabase>()));
  getIt.registerSingleton<SecurityFilterChain>(
      SecurityFilterChain(getIt<TokenService>()));
  getIt.registerSingleton<AuthService>(
      AuthService(getIt<InMemoryUserRepository>(), getIt<TokenService>()));
  getIt.registerSingleton<RouterProvider>(RouterProvider(getIt<AuthService>()));

  final pipeline = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(getIt<SecurityFilterChain>().middleware)
      .addHandler(getIt<RouterProvider>().handler);

  final server = await shelf_io.serve(pipeline, 'localhost', 8080);
  server.autoCompress = true;
  print('Serving at http://${server.address.host}:${server.port}');
}
