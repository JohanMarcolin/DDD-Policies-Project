import 'package:mocktail/mocktail.dart';
import 'package:client/infrastructure/apis/auth_api.dart';

/// A mock implementation of [AuthApi] for testing purposes.
///
/// This class allows tests to stub and verify authentication-related API calls.
class MockAuthApi extends Mock implements AuthApi {}
