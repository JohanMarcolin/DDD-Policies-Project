import 'package:domain/repositories/user_repository.dart' as domain;
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements domain.UserRepository {}
