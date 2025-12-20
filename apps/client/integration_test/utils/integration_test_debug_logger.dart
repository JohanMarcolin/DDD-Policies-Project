import 'package:flutter/foundation.dart';

/// A logger for integration tests.
///
/// Use this class to log messages in integration tests.
/// Provide a [tag] to identify the source of the logs.
class IntegrationTestDebugLogger {
  IntegrationTestDebugLogger({required this.tag});

  final String tag;

  void authorized(String message) => _debug('🟢 [$tag] $message');

  void unauthorized(String message) => _debug('🔴 [$tag] $message');

  /// Logs [message] if the test is running in debug mode.
  void _debug(String message) {
    if (kDebugMode) debugPrint(message);
  }
}
