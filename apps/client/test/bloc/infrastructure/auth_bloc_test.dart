import 'dart:async';

import 'package:client/infrastructure/auth_bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:client/infrastructure/apis/auth_api.dart';
import 'package:test_utils/mocks/mock_user_credentials.dart';
import 'package:test_utils/mocks/mock_users.dart';

class MockAuthApi extends Mock implements AuthApi {}

class AuthBlocTestContext {
  late MockAuthApi mockApi;
  late AuthBloc bloc;

  void setup() {
    mockApi = MockAuthApi();
    bloc = AuthBloc(authApi: mockApi);
  }
}

final blocTestContext = AuthBlocTestContext();

void _blocTest({
  required String description,
  void Function()? stub,
  void Function(AuthBloc bloc)? act,
  List<dynamic> Function()? expect,
  required FutureOr<void> Function(AuthBloc) verify,
}) {
  blocTest<AuthBloc, AuthState>(
    description,
    setUp: () {
      blocTestContext.setup();
      stub?.call();
    },
    build: () => blocTestContext.bloc,
    act: act,
    expect: expect,
    verify: verify,
  );
}

void main() {
  group('AuthBloc', () {
    group('{Initialization}', () {
      _blocTest(
        description: 'should initialize with expected state',
        verify: (bloc) => expect(bloc.state, isA<AuthInitial>()),
      );
    });

    group('{Events}', () {
      group('{AuthLoginRequested}', () {
        _blocTest(
          description: 'should emit AuthLoading and Authenticated on successful login',
          stub: () => when(
            () => blocTestContext.mockApi.login(email: mockValidEmail, password: mockValidPassword),
          ).thenAnswer((_) async => mockUser),
          act: (bloc) => bloc.add(AuthLoginRequested(email: mockValidEmail, password: mockValidPassword)),
          expect: () => [
            isA<AuthLoading>(),
            isA<Authenticated>().having((s) => s.currentUser, 'currentUser', mockUser),
          ],
          verify: (bloc) => expect(bloc.state, isA<Authenticated>()),
        );

        _blocTest(
          description: 'should not authenticate on invalid credentials',
          stub: () => when(
            () => blocTestContext.mockApi.login(email: mockInvalidEmail, password: mockTooShortPassword),
          ).thenThrow(AuthApiException('INVALID_CREDENTIALS')),
          act: (bloc) => bloc.add(AuthLoginRequested(email: mockInvalidEmail, password: mockTooShortPassword)),
          expect: () => [isA<AuthLoading>(), isA<Unauthenticated>().having((s) => s.errorCode, 'errorCode', isNotNull)],
          verify: (bloc) => expect(bloc.state, isA<Unauthenticated>()),
        );
      });

      group('{AuthRefreshRequested}', () {
        _blocTest(
          description: 'should emit AuthLoading and Authenticated on successful refresh',
          stub: () => when(() => blocTestContext.mockApi.refreshAccessToken()).thenAnswer((_) async => mockUser),
          act: (bloc) => bloc.add(AuthRefreshRequested()),
          expect: () => [
            isA<AuthLoading>(),
            isA<Authenticated>().having((s) => s.currentUser, 'currentUser', mockUser),
          ],
          verify: (bloc) => expect(bloc.state, isA<Authenticated>()),
        );

        _blocTest(
          description: 'should not authenticate on refresh failure',
          stub: () =>
              when(() => blocTestContext.mockApi.refreshAccessToken()).thenThrow(AuthApiException('TOKEN_EXPIRED')),
          act: (bloc) => bloc.add(AuthRefreshRequested()),
          expect: () => [isA<AuthLoading>(), isA<Unauthenticated>().having((s) => s.errorCode, 'errorCode', isNotNull)],
          verify: (bloc) => expect(bloc.state, isA<Unauthenticated>()),
        );
      });

      group('{AuthLogoutRequested}', () {
        _blocTest(
          description: 'should emit AuthLoading and Unauthenticated on successful logout',
          stub: () => when(() => blocTestContext.mockApi.logout()).thenAnswer((_) async {}),
          act: (bloc) => bloc.add(AuthLogoutRequested()),
          expect: () => [isA<AuthLoading>(), isA<Unauthenticated>()],
          verify: (bloc) => expect(bloc.state, isA<Unauthenticated>()),
        );

        _blocTest(
          description: 'should not emit Unauthenticated on logout failure',
          stub: () => when(() => blocTestContext.mockApi.logout()).thenThrow(Exception('Logout failed')),
          act: (bloc) => bloc.add(AuthLogoutRequested()),
          expect: () => [isA<AuthLoading>(), isA<AuthFailure>()],
          verify: (bloc) => expect(bloc.state, isA<AuthFailure>()),
        );
      });
    });
  });
}
