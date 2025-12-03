import 'package:client/infrastructure/auth_bloc/auth_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../test_utils/mock_auth_api.dart';

/// Test fixture for orchestrating [AuthBloc] tests.
///
/// Encapsulates setup and dependency management for [AuthBloc] tests.
///
/// Usage:
/// - Use [mockBloc] to dispatch events or check state.
/// - Use [mockApi] to stub or verify that API methods were called.
/// - Call [test] to run a [blocTest] with all dependencies set up.
class AuthBlocTestFixture {
  late MockAuthApi mockApi;
  late AuthBloc mockBloc;

  /// Runs a [blocTest] with all dependencies set up.
  ///
  /// - [description]: Test case description.
  /// - [stub]: Optional function to stub [mockApi] methods.
  /// - [act]: Optional function to dispatch [mockBloc] events.
  /// - [expect]: Optional function for ensuring expected state transitions.
  /// - [verify]: Required function to verify final [mockBloc] state.
  void test({
    required String description,
    void Function()? stub,
    void Function(AuthBloc bloc)? act,
    List<dynamic> Function()? expect,
    required Future<void> Function(AuthBloc) verify,
  }) {
    blocTest<AuthBloc, AuthState>(
      description,
      setUp: () {
        mockApi = MockAuthApi();
        mockBloc = AuthBloc(authApi: mockApi);
        stub?.call();
      },
      build: () => mockBloc,
      act: act,
      expect: expect,
      verify: verify,
    );
  }
}
