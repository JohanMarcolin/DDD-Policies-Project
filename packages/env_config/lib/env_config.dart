import 'package:envied/envied.dart';

part 'env_config.g.dart';

/// A class that provides access to environment variables defined in the `.env` file.
///
/// Use this for server and API configuration.
@Envied(path: '.env')
abstract class Env {
  /// Represents the host address of the server.
  @EnviedField(varName: 'SERVER_HOST')
  static const String serverHost = _Env.serverHost;

  /// Represents the port number the server listens on.
  @EnviedField(varName: 'SERVER_PORT')
  static const int serverPort = _Env.serverPort;

  /// Indicates whether development users should be seeded on the server.
  static bool get serverShouldSeedTestUsers =>
      const String.fromEnvironment('SERVER_SHOULD_SEED_DEVELOPMENT_USERS').toLowerCase() == 'true';

  /// Represents the base URL for the server when accessed from the Android emulator.
  @EnviedField(varName: 'ANDROID_EMULATOR_SERVER_BASE_URL')
  static const String androidEmulatorServerBaseUrl = _Env.androidEmulatorServerBaseUrl;

  /// Represents the expiration time for access tokens in minutes.
  @EnviedField(varName: 'ACCESS_TOKEN_EXPIRATION_MINUTES')
  static const int accessTokenExpirationMinutes = _Env.accessTokenExpirationMinutes;

  /// Represents the expiration time for refresh tokens in days.
  @EnviedField(varName: 'REFRESH_TOKEN_EXPIRATION_DAYS')
  static const int refreshTokenExpirationDays = _Env.refreshTokenExpirationDays;
}
