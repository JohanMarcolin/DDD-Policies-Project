import 'package:client/infrastructure/auth_bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:client/infrastructure/apis/auth_api.dart';
import 'package:test_utils/mocks/mock_user_credentials.dart';
import 'package:test_utils/mocks/mock_users.dart';
import 'auth_bloc_test_fixture.dart';

final _blocFixture = AuthBlocTestFixture();

void main() {
  group('AuthBloc', () {
    group('{Initialization}', () {
      _blocFixture.test(
        description: 'should initialize with expected state',
        verify: (bloc) async => expect(bloc.state, isA<AuthInitial>()),
      );
    });

    group('{Events}', () {
      group('{AuthLoginRequested}', () {
        _blocFixture.test(
          description: 'should emit AuthLoading and Authenticated on successful login',
          stub: () => when(
            () => _blocFixture.mockApi.login(email: mockValidEmail, password: mockValidPassword),
          ).thenAnswer((_) async => mockUser),
          act: (bloc) => bloc.add(AuthLoginRequested(email: mockValidEmail, password: mockValidPassword)),
          expect: () => [
            isA<AuthLoading>(),
            isA<Authenticated>().having((s) => s.currentUser, 'currentUser', mockUser),
          ],
          verify: (bloc) async => expect(bloc.state, isA<Authenticated>()),
        );

        _blocFixture.test(
          description: 'should not authenticate on invalid credentials',
          stub: () => when(
            () => _blocFixture.mockApi.login(email: mockInvalidEmail, password: mockTooShortPassword),
          ).thenThrow(AuthApiException('INVALID_CREDENTIALS')),
          act: (bloc) => bloc.add(AuthLoginRequested(email: mockInvalidEmail, password: mockTooShortPassword)),
          expect: () => [
            isA<AuthLoading>(),
            isA<Unauthenticated>().having((s) => s.apiErrorCode, 'apiErrorCode', isNotNull),
          ],
          verify: (bloc) async => expect(bloc.state, isA<Unauthenticated>()),
        );
      });

      group('{AuthRefreshAccessTokenRequested}', () {
        _blocFixture.test(
          description: 'should emit AuthLoading and Authenticated on successful refresh',
          stub: () => when(() => _blocFixture.mockApi.refreshAccessToken()).thenAnswer((_) async => mockUser),
          act: (bloc) => bloc.add(AuthRefreshAccessTokenRequested()),
          expect: () => [
            isA<AuthLoading>(),
            isA<Authenticated>().having((s) => s.currentUser, 'currentUser', mockUser),
          ],
          verify: (bloc) async => expect(bloc.state, isA<Authenticated>()),
        );

        _blocFixture.test(
          description: 'should not authenticate on refresh failure',
          stub: () =>
              when(() => _blocFixture.mockApi.refreshAccessToken()).thenThrow(AuthApiException('TOKEN_EXPIRED')),
          act: (bloc) => bloc.add(AuthRefreshAccessTokenRequested()),
          expect: () => [
            isA<AuthLoading>(),
            isA<Unauthenticated>().having((s) => s.apiErrorCode, 'apiErrorCode', isNotNull),
          ],
          verify: (bloc) async => expect(bloc.state, isA<Unauthenticated>()),
        );
      });

      group('{AuthLogoutRequested}', () {
        _blocFixture.test(
          description: 'should emit AuthLoading and Unauthenticated on successful logout',
          stub: () => when(() => _blocFixture.mockApi.logout()).thenAnswer((_) async {}),
          act: (bloc) => bloc.add(AuthLogoutRequested()),
          expect: () => [isA<AuthLoading>(), isA<Unauthenticated>()],
          verify: (bloc) async => expect(bloc.state, isA<Unauthenticated>()),
        );

        _blocFixture.test(
          description: 'should not emit Unauthenticated on logout failure',
          stub: () => when(() => _blocFixture.mockApi.logout()).thenThrow(Exception('Logout failed')),
          act: (bloc) => bloc.add(AuthLogoutRequested()),
          expect: () => [isA<AuthLoading>(), isA<AuthFailure>()],
          verify: (bloc) async => expect(bloc.state, isA<AuthFailure>()),
        );
      });
    });
  });
}
