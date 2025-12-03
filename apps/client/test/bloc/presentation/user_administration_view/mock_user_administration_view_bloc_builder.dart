import 'package:client/presentation/views/user_administration_view/blocs/users_view_bloc/user_administration_view_bloc.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:test_utils/mocks/mock_user_repository.dart';

/// Builder for creating a [UserAdministrationViewBloc] and its stubbed dependencies for testing.
///
/// Use this builder to set up a mock [UserRepository] and a [UserAdministrationViewBloc] for [blocTest] and [blocPresentationTest].
/// Provides direct access to the mock repository and bloc, and a [dispose] method to clean up resources after tests.
class MockUserAdministrationViewBlocBuilder {
  MockUserAdministrationViewBlocBuilder._(this.mockRepository, this.mockBloc);

  /// The mock [UserRepository] used by the [UserAdministrationViewBloc].
  final MockUserRepository mockRepository;

  /// The [UserAdministrationViewBloc] instance created for testing.
  final UserAdministrationViewBloc mockBloc;

  /// Disposes the bloc and releases resources after tests.
  void dispose() => mockBloc.close();

  /// Provides the builder for a given [currentUser].
  ///
  /// - [currentUser]: The user context for the bloc being constructed.
  ///
  /// Returns a builder with initialized mock repository and bloc.
  factory MockUserAdministrationViewBlocBuilder({required User currentUser}) {
    final mockRepository = _createMockRepository();
    final mockService = _createMockService(mockRepository);
    final mockBloc = _createMockBloc(currentUser, mockService);
    return MockUserAdministrationViewBlocBuilder._(mockRepository, mockBloc);
  }

  /// Instantiates a mock [UserRepository].
  static MockUserRepository _createMockRepository() => MockUserRepository();

  /// Instantiates a [UserAdministrationService] with its required policies.
  static UserAdministrationService _createMockService(MockUserRepository mockRepository) {
    return UserAdministrationService(
      userRepository: mockRepository,
      viewUserPolicy: ViewUserPolicy(),
      updateUserEmailPolicy: UpdateUserEmailPolicy(),
      updateUserPasswordPolicy: UpdateUserPasswordPolicy(),
      deleteUserPolicy: DeleteUserPolicy(),
      emailValidationPolicy: EmailValidationPolicy(),
      passwordValidationPolicy: PasswordValidationPolicy(),
    );
  }

  /// Instantiates a [UserAdministrationViewBloc] for the given [currentUser] and [mockService].
  static UserAdministrationViewBloc _createMockBloc(User currentUser, UserAdministrationService mockService) {
    return UserAdministrationViewBloc(currentUser: currentUser, userAdministrationService: mockService);
  }
}
