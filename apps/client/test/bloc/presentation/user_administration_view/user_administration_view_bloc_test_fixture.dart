import 'dart:async';

import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:domain/entities/user.dart';
import 'package:test_utils/mocks/mock_user_repository.dart';
import 'package:client/presentation/views/user_administration_view/blocs/users_view_bloc/user_administration_view_bloc.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:domain/services/user_administration/user_administration_service.dart';

/// Utility for setting up and managing UserAdministrationViewBloc test dependencies.
///
/// Intended for use with [blocTest] and [blocPresentationTest] for [UserAdministrationViewBloc] only.
/// Provides a structured way to initialize the Bloc and its repository for user administration tests.
class UserAdministrationViewBlocTestFixture {
  late UserAdministrationViewBloc mockBloc;
  late MockUserRepository mockRepository;
  late void Function() dispose;

  void test({
    required String description,
    required User currentUser,
    required User targetUser,
    void Function()? stub,
    void Function(UserAdministrationViewBloc bloc)? act,
    List<dynamic> Function()? expect,
    required FutureOr<void> Function(UserAdministrationViewBloc) verify,
  }) {
    blocTest<UserAdministrationViewBloc, UserAdministrationViewState>(
      description,
      setUp: () {
        _setup(currentUser);
        stub?.call();
      },
      build: () => mockBloc,
      act: act,
      expect: expect,
      verify: verify,
    );
  }

  void testPresentation({
    required String description,
    required User currentUser,
    required User targetUser,
    void Function()? stub,
    required UserAdministrationViewEvent event,
    required dynamic Function() expectPresentation,
    required FutureOr<void> Function(UserAdministrationViewBloc) verify,
  }) {
    blocPresentationTest<UserAdministrationViewBloc, UserAdministrationViewState, UserAdministrationViewEvent>(
      description,
      setUp: () {
        _setup(currentUser);
        stub?.call();
      },
      build: () => mockBloc,
      act: (bloc) => bloc.add(event),
      expectPresentation: expectPresentation,
      verify: verify,
    );
  }

  /// Initializes the builder, Bloc, and repository for the given [currentUser].
  ///
  /// Call this in your test setup to prepare all dependencies for the UserAdministrationViewBloc.
  void _setup(User currentUser) {
    final builder = _UserAdministrationViewBlocBuilder(currentUser: currentUser);
    mockBloc = builder.mockBloc;
    mockRepository = builder.mockRepository;
    dispose = builder.dispose;
  }
}

/// Builder for creating a [UserAdministrationViewBloc] and its stubbed dependencies for testing purposes.
///
/// Use this builder to set up a mock [UserRepository] and a [UserAdministrationViewBloc] for [blocTest] and [blocPresentationTest].
/// Provides direct access to the mock repository and bloc, and a [dispose] method to clean up resources after tests.
class _UserAdministrationViewBlocBuilder {
  _UserAdministrationViewBlocBuilder._(this.mockRepository, this.mockBloc);

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
  factory _UserAdministrationViewBlocBuilder({required User currentUser}) {
    final mockRepository = _createMockRepository();
    final mockService = _createMockService(mockRepository);
    final mockBloc = _createMockBloc(currentUser, mockService);
    return _UserAdministrationViewBlocBuilder._(mockRepository, mockBloc);
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
