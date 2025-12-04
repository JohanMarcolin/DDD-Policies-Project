import 'package:domain/repositories/user_repository.dart' as domain;
import 'package:mocktail/mocktail.dart';

/// Provides a mock implementation of [UserRepository] for testing purposes.
///
/// Use this class to stub user repository behavior.
class MockUserRepository extends Mock implements domain.UserRepository {}
