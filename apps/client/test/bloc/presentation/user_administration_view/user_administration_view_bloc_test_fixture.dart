import 'dart:async';

import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:domain/entities/user.dart';
import 'package:test_utils/mocks/mock_user_repository.dart';
import 'package:client/presentation/views/user_administration_view/blocs/users_view_bloc/user_administration_view_bloc.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:domain/services/user_administration/user_administration_service.dart';

/// Test fixture for orchestrating [UserAdministrationViewBloc] tests.
///
/// Encapsulates setup, dependency management, and teardown logic for [UserAdministrationViewBloc] tests.
///
/// Usage:
/// - Use [mockBloc], e.g., to dispatch events or check state.
/// - Use [mockRepository], e.g., to stub or verify that repository methods were called.
/// - Call [dispose] to clean up resources after each test.
/// - Call [test] to run a [blocTest].
/// - Call [testPresentation] to run a [blocPresentationTest].
class UserAdministrationViewBlocTestFixture {
  late UserAdministrationViewBloc mockBloc;
  late MockUserRepository mockRepository;
  late void Function() dispose = () => mockBloc.close();

  /// Runs a [blocTest] with all dependencies set up.
  ///
  /// - [description]: Test case description.
  /// - [currentUser]: The acting user within the test context.
  /// - [targetUser]: The user being acted upon.
  /// - [stub]: Optional function to stub [mockRepository] methods.
  /// - [act]: Optional function to dispatch [mockBloc] events.
  /// - [expect]: Optional function for ensuring expected state transitions.
  /// - [verify]: Required function to verify final [mockBloc] state.
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

  /// Runs a [blocPresentationTest] with all dependencies set up.
  ///
  /// - [description]: Test case description.
  /// - [currentUser]: The acting user within the test context.
  /// - [targetUser]: The user being acted upon.
  /// - [stub]: Optional function to stub [mockRepository] methods.
  /// - [event]: The event to dispatch to the bloc.
  /// - [expectPresentation]: Function returning expected presentation outputs.
  /// - [verify]: Required function to verify final [mockBloc] state.
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

  /// Sets up new instances of [mockBloc] and [mockRepository] for the given [currentUser].
  ///
  /// This method is called internally by the fixture before every test case.
  /// It ensures that each test runs in an isolated environment, with new instances of the bloc and repository.
  void _setup(User currentUser) {
    final builder = _UserAdministrationViewBlocBuilder(currentUser: currentUser);
    mockBloc = builder.mockBloc;
    mockRepository = builder.mockRepository;
  }
}

/// Internal builder for creating a [UserAdministrationViewBloc] and its stubbed dependencies for tests.
///
/// Used by [UserAdministrationViewBlocTestFixture] to provide fresh bloc and repository instances per test.
class _UserAdministrationViewBlocBuilder {
  _UserAdministrationViewBlocBuilder._(this.mockRepository, this.mockBloc);

  /// The mock [UserRepository] used by the [UserAdministrationViewBloc].
  final MockUserRepository mockRepository;

  /// The [UserAdministrationViewBloc] instance created for testing.
  final UserAdministrationViewBloc mockBloc;

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

  /// Instantiates a [UserAdministrationService] for the given [mockRepository] with its required policies.
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
