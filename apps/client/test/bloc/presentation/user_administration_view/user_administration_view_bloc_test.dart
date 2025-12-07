import 'package:client/presentation/views/user_administration_view/blocs/users_view_bloc/user_administration_view_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/domain/user_administration_service.dart';
import 'package:test_utils/mocks/mock_user_credentials.dart';
import 'package:test_utils/mocks/mock_users.dart';
import 'package:test_utils/user_pair_test_util.dart';
import 'package:mocktail/mocktail.dart';
import 'user_administration_view_bloc_test_fixture.dart';

final blocFixture = UserAdministrationViewBlocTestFixture();

final userAdministrationService = createStubbedUserAdministrationService();

void main() {
  tearDown(() {
    blocFixture.dispose();
  });

  group('UserAdministrationViewBloc', () {
    group('{Initialization}', () {
      UserPairTestUtil.forEachUserPair(
        users: distinctMockUsers,
        onUserPair: (currentUser, targetUser) {
          blocFixture.test(
            description: 'should initialize with expected state',
            currentUser: currentUser,
            targetUser: targetUser,
            verify: (bloc) => expect(bloc.state, isA<UserAdministrationViewInitial>()),
          );
        },
      );
    });

    group('{Events}', () {
      group('{FetchUsersRequested Event}', () {
        UserPairTestUtil.forEachUserPair(
          users: allMockUserPairs,
          onUserPair: (initiator, target) {
            userAdministrationService.authorizeViewUser(
              initiator: initiator,
              target: target,
              onAuthorized: () {
                blocFixture.test(
                  description:
                      'fetched users should include users with role ${target.role.name} when FetchUsersRequested is added',
                  currentUser: initiator,
                  targetUser: target,
                  stub: () => when(() => blocFixture.mockRepository.users).thenAnswer((_) async => allMockUserPairs),
                  act: (bloc) => bloc.add(FetchUsersRequested()),
                  expect: () => [isA<UserAdministrationViewLoading>(), isA<UserAdministrationViewLoaded>()],
                  verify: (bloc) {
                    final state = bloc.state;
                    expect(state, isA<UserAdministrationViewLoaded>());
                    if (state is UserAdministrationViewLoaded) {
                      expect(state.users.contains(target), isTrue);
                    }
                  },
                );
                blocFixture.test(
                  description: 'fetched users should emit failure when repo throws on FetchUsersRequested',
                  currentUser: initiator,
                  targetUser: target,
                  stub: () => when(() => blocFixture.mockRepository.users).thenThrow(Exception('fetch error')),
                  act: (bloc) => bloc.add(FetchUsersRequested()),
                  expect: () => [isA<UserAdministrationViewLoading>(), isA<UserAdministrationViewFailure>()],
                  verify: (bloc) {
                    expect(bloc.state, isA<UserAdministrationViewFailure>());
                  },
                );
              },
              onUnauthorized: (_) {
                blocFixture.test(
                  description:
                      'fetched users should not include users with role ${target.role.name} when FetchUsersRequested is added',
                  currentUser: initiator,
                  targetUser: target,
                  stub: () => when(() => blocFixture.mockRepository.users).thenAnswer((_) async => allMockUserPairs),
                  act: (bloc) => bloc.add(FetchUsersRequested()),
                  expect: () => [isA<UserAdministrationViewLoading>(), isA<UserAdministrationViewLoaded>()],
                  verify: (bloc) {
                    final state = bloc.state;
                    expect(state, isA<UserAdministrationViewLoaded>());
                    if (state is UserAdministrationViewLoaded) {
                      expect(state.users.contains(target), isFalse);
                    }
                  },
                );
              },
            );
          },
        );
        group('{DeleteUserRequested Event}', () {
          UserPairTestUtil.forEachUserPair(
            users: allMockUserPairs,
            onUserPair: (initiator, target) {
              userAdministrationService.authorizeDeleteUser(
                initiator: initiator,
                target: target,
                onAuthorized: () {
                  final isDeletingSelf = initiator.isSameAs(target);

                  blocFixture.testPresentation(
                    description: 'should delete user when DeleteUserRequested is added',
                    currentUser: initiator,
                    targetUser: target,
                    stub: () =>
                        when(() => blocFixture.mockRepository.delete(userId: target.userId)).thenAnswer((_) async {}),
                    event: DeleteUserRequested(targetUser: target),
                    expectPresentation: () => isDeletingSelf ? [isA<DeleteSelfSuccess>()] : [isA<DeleteUserSuccess>()],
                    verify: (bloc) => verify(() => blocFixture.mockRepository.delete(userId: target.userId)).called(1),
                  );

                  blocFixture.testPresentation(
                    description: 'should emit failure when repo throws on DeleteUserRequested',
                    currentUser: initiator,
                    targetUser: target,
                    stub: () => when(
                      () => blocFixture.mockRepository.delete(userId: target.userId),
                    ).thenThrow(Exception('delete error')),
                    event: DeleteUserRequested(targetUser: target),
                    expectPresentation: () => [isA<DeleteUserFailure>()],
                    verify: (bloc) {},
                  );
                },
                onUnauthorized: (_) {
                  blocFixture.testPresentation(
                    description: 'should not delete user when DeleteUserRequested is added',
                    currentUser: initiator,
                    targetUser: target,
                    stub: () =>
                        when(() => blocFixture.mockRepository.delete(userId: target.userId)).thenAnswer((_) async {}),
                    event: DeleteUserRequested(targetUser: target),
                    expectPresentation: () => [isA<DeleteUserFailure>()],
                    verify: (bloc) => verifyNever(() => blocFixture.mockRepository.delete(userId: target.userId)),
                  );
                },
              );
            },
          );
        });

        group('{UpdateUserEmailRequested Event}', () {
          UserPairTestUtil.forEachUserPair(
            users: allMockUserPairs,
            onUserPair: (initiator, target) {
              userAdministrationService.authorizeUpdateUserEmail(
                initiator: initiator,
                target: target,
                onAuthorized: () {
                  blocFixture.testPresentation(
                    description: 'should update user email with valid new email when UpdateUserEmailRequested is added',
                    currentUser: initiator,
                    targetUser: target,
                    stub: () => when(
                      () => blocFixture.mockRepository.updateEmail(userId: target.userId, newEmail: mockValidEmail),
                    ).thenAnswer((_) async {}),
                    event: UpdateUserEmailRequested(targetUser: target, newEmail: mockValidEmail),
                    expectPresentation: () => [isA<UpdateUserEmailSuccess>()],
                    verify: (bloc) => verify(
                      () => blocFixture.mockRepository.updateEmail(userId: target.userId, newEmail: mockValidEmail),
                    ).called(1),
                  );
                  blocFixture.testPresentation(
                    description: 'should emit failure when repo throws on UpdateUserEmailRequested',
                    currentUser: initiator,
                    targetUser: target,
                    stub: () => when(
                      () => blocFixture.mockRepository.updateEmail(userId: target.userId, newEmail: mockValidEmail),
                    ).thenThrow(Exception('update email error')),
                    event: UpdateUserEmailRequested(targetUser: target, newEmail: mockValidEmail),
                    expectPresentation: () => [isA<UpdateUserEmailFailure>()],
                    verify: (bloc) {},
                  );
                  blocFixture.testPresentation(
                    description:
                        'should not update user email with invalid new email when UpdateUserEmailRequested is added',
                    currentUser: initiator,
                    targetUser: target,
                    stub: () => when(
                      () => blocFixture.mockRepository.updateEmail(userId: target.userId, newEmail: mockInvalidEmail),
                    ).thenAnswer((_) async {}),
                    event: UpdateUserEmailRequested(targetUser: target, newEmail: mockInvalidEmail),
                    expectPresentation: () => [isA<UpdateUserEmailInvalid>()],
                    verify: (bloc) => verifyNever(
                      () => blocFixture.mockRepository.updateEmail(userId: target.userId, newEmail: mockInvalidEmail),
                    ),
                  );
                },
                onUnauthorized: (_) {
                  for (final newEmail in [mockValidEmail, mockInvalidEmail]) {
                    blocFixture.testPresentation(
                      description:
                          'should not update user email with any new email when UpdateUserEmailRequested is added',
                      currentUser: initiator,
                      targetUser: target,
                      stub: () => when(
                        () => blocFixture.mockRepository.updateEmail(userId: target.userId, newEmail: newEmail),
                      ).thenAnswer((_) async {}),
                      event: UpdateUserEmailRequested(targetUser: target, newEmail: newEmail),
                      expectPresentation: () => [anyOf(isA<UpdateUserEmailInvalid>(), isA<UpdateUserEmailFailure>())],
                      verify: (bloc) => verifyNever(
                        () => blocFixture.mockRepository.updateEmail(userId: target.userId, newEmail: newEmail),
                      ),
                    );
                  }
                },
              );
            },
          );
        });

        group('{UpdateUserPasswordRequested Event}', () {
          UserPairTestUtil.forEachUserPair(
            users: allMockUserPairs,
            onUserPair: (initiator, target) {
              userAdministrationService.authorizeUpdateUserPassword(
                initiator: initiator,
                target: target,
                onAuthorized: () {
                  blocFixture.testPresentation(
                    description:
                        'should update user password with valid new password when UpdateUserPasswordRequested is added',
                    currentUser: initiator,
                    targetUser: target,
                    stub: () => when(
                      () => blocFixture.mockRepository.updatePassword(
                        userId: target.userId,
                        newPassword: mockValidPassword,
                      ),
                    ).thenAnswer((_) async {}),
                    event: UpdateUserPasswordRequested(targetUser: target, newPassword: mockValidPassword),
                    expectPresentation: () => [isA<UpdateUserPasswordSuccess>()],
                    verify: (bloc) => verify(
                      () => blocFixture.mockRepository.updatePassword(
                        userId: target.userId,
                        newPassword: mockValidPassword,
                      ),
                    ).called(1),
                  );
                  blocFixture.testPresentation(
                    description: 'should emit failure when repo throws on UpdateUserPasswordRequested',
                    currentUser: initiator,
                    targetUser: target,
                    stub: () => when(
                      () => blocFixture.mockRepository.updatePassword(
                        userId: target.userId,
                        newPassword: mockValidPassword,
                      ),
                    ).thenThrow(Exception('update password error')),
                    event: UpdateUserPasswordRequested(targetUser: target, newPassword: mockValidPassword),
                    expectPresentation: () => [isA<UpdateUserPasswordFailure>()],
                    verify: (bloc) {},
                  );
                  blocFixture.testPresentation(
                    description:
                        'should not update user password with invalid new password when UpdateUserPasswordRequested is added',
                    currentUser: initiator,
                    targetUser: target,
                    stub: () => when(
                      () => blocFixture.mockRepository.updatePassword(
                        userId: target.userId,
                        newPassword: mockTooShortPassword,
                      ),
                    ).thenAnswer((_) async {}),
                    event: UpdateUserPasswordRequested(targetUser: target, newPassword: mockTooShortPassword),
                    expectPresentation: () => [isA<UpdateUserPasswordInvalid>()],
                    verify: (bloc) => verifyNever(
                      () => blocFixture.mockRepository.updatePassword(
                        userId: target.userId,
                        newPassword: mockTooShortPassword,
                      ),
                    ),
                  );
                },
                onUnauthorized: (_) {
                  for (final newPassword in [mockValidPassword, mockTooShortPassword]) {
                    blocFixture.testPresentation(
                      description:
                          'should not update user password with any new password when UpdateUserPasswordRequested is added',
                      currentUser: initiator,
                      targetUser: target,
                      stub: () => when(
                        () =>
                            blocFixture.mockRepository.updatePassword(userId: target.userId, newPassword: newPassword),
                      ).thenAnswer((_) async {}),
                      event: UpdateUserPasswordRequested(targetUser: target, newPassword: newPassword),
                      expectPresentation: () => [
                        anyOf(isA<UpdateUserPasswordInvalid>(), isA<UpdateUserPasswordFailure>()),
                      ],
                      verify: (bloc) => verifyNever(
                        () =>
                            blocFixture.mockRepository.updatePassword(userId: target.userId, newPassword: newPassword),
                      ),
                    );
                  }
                },
              );
            },
          );
        });
      });
    });
  });
}
