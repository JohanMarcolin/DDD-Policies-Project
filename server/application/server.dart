import 'package:get_it/get_it.dart';

import 'authentication/auth_service.dart';
import 'databases/refresh_token_database.dart';
import 'databases/user_database.dart';
import 'repositories/in_memory_user_repository.dart';
import 'security/token_service.dart';
import 'router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'security/security_filter_chain.dart';

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
