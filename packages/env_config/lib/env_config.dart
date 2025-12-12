import 'package:envied/envied.dart';

part 'env_config.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'SERVER_HOST')
  static const String serverHost = _Env.serverHost;

  @EnviedField(varName: 'SERVER_PORT')
  static const int serverPort = _Env.serverPort;

  @EnviedField(varName: 'ANDROID_EMULATOR_BASE_URL')
  static const String androidEmulatorBaseUrl = _Env.androidEmulatorBaseUrl;

  @EnviedField(varName: 'IOS_SIMULATOR_BASE_URL')
  static const String iosSimulatorBaseUrl = _Env.iosSimulatorBaseUrl;
}
