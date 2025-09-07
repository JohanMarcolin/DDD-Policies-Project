import 'package:get_it/get_it.dart';
import 'package:shelf_router/shelf_router.dart';

import '../../domain/services/user_administration/user_administration_service.dart';
import '../infrastructure/databases/user_password_database.dart';
import '../infrastructure/factories/mock_user_factory.dart';
import '../infrastructure/repositories/in_memory_user_repository.dart';
import '../infrastructure/security/password_hasher.dart';
import 'route_providers/auth_route_provider.dart';
import '../infrastructure/services/auth_service.dart';
import '../infrastructure/databases/refresh_token_database.dart';
import '../infrastructure/databases/user_database.dart';
import '../infrastructure/security/token_service.dart';
import 'route_providers/user_route_provider.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import '../infrastructure/security/security_filter_chain.dart';

final getIt = GetIt.instance;

void main() async {
  getIt.registerSingleton<Router>(Router());
  getIt.registerSingleton<UserDatabase>(UserDatabase());
  getIt.registerSingleton<PasswordHasher>(PasswordHasher());
  getIt.registerSingleton<UserPasswordDatabase>(
      UserPasswordDatabase(getIt<PasswordHasher>()));
  getIt.registerSingleton<InMemoryUserRepository>(InMemoryUserRepository(
      getIt<UserDatabase>(), getIt<UserPasswordDatabase>()));
  getIt.registerSingleton<RefreshTokenDatabase>(RefreshTokenDatabase());
  getIt.registerSingleton<TokenService>(
      TokenService(getIt<RefreshTokenDatabase>()));
  getIt.registerSingleton<SecurityFilterChain>(
      SecurityFilterChain(getIt<TokenService>()));
  getIt.registerSingleton<AuthService>(
      AuthService(getIt<InMemoryUserRepository>(), getIt<TokenService>()));
  getIt.registerSingleton<AuthRouteProvider>(
      AuthRouteProvider(getIt<AuthService>()));
  getIt.registerSingleton<UserAdministrationService>(
      UserAdministrationService(getIt<InMemoryUserRepository>()));
  getIt.registerSingleton<UserRouteProvider>(
      UserRouteProvider(getIt<UserAdministrationService>()));

  getIt<AuthRouteProvider>().appendRoutes(getIt<Router>());
  getIt<UserRouteProvider>().appendRoutes(getIt<Router>());

  final pipeline = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(getIt<SecurityFilterChain>().middleware)
      .addHandler(getIt<Router>());

  _setupMockUsers();

  final server = await shelf_io.serve(pipeline, 'localhost', 8080);
  server.autoCompress = true;
  print('Serving at http://${server.address.host}:${server.port}');
}

void _setupMockUsers() {
  for (final entry in MockUserFactory.createDefaultUsersWithPasswords()) {
    final user = entry.keys.first;
    final password = entry.values.first;
    final hashedPassword = getIt<PasswordHasher>().hash(password);

    getIt<UserDatabase>().put(user.id, user);
    getIt<UserPasswordDatabase>().put(user.id, hashedPassword);
  }
}
