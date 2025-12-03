import 'package:client/presentation/views/user_administration_view/blocs/users_view_bloc/user_administration_view_bloc.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/mocks/mock_user_credentials.dart';
import 'package:test_utils/mocks/mock_users.dart';
import 'package:test_utils/user_test_runner.dart';
import 'package:mocktail/mocktail.dart';
import 'user_administration_view_bloc_test_fixture.dart';

final blocFixture = UserAdministrationViewBlocTestFixture();

void main() {
  tearDown(() {
    blocFixture.dispose();
  });

  group('UserAdministrationViewBloc', () {
    group('{Initialization}', () {
      UserTestRunner.forEachUserPair(
        users: allMockUserPairs,
        onUserPairCase: (currentUser, targetUser) {
          blocFixture.test(
            description: 'should initialize with expected state',
            currentUser: currentUser,
            targetUser: targetUser,
            verify: (bloc) => expect(bloc.state, isA<UserAdministrationViewInitial>()),
          );
        },
      );
    });

    group('{Public Methods}', () {
      group('{Authorization Methods}', () {
        UserTestRunner.forEachUserPair(
          users: [mockUser, otherMockUser],
          onUserPairCase: (currentUser, targetUser) {
            blocFixture.test(
              description: 'should check if user is administrating self',
              currentUser: currentUser,
              targetUser: targetUser,
              verify: (bloc) {
                expect(bloc.isAdministratingSelf(targetUser), equals(currentUser.isSameAs(targetUser)));
              },
            );
          },
        );
      });

      group('{Authorization Methods}', () {
        UserTestRunner.forEachUserPair(
          users: [mockUser, mockAdmin, mockAnalyst],
          onUserPairCase: (currentUser, targetUser) {
            final targetUserRole = targetUser.role.name;

            blocFixture.test(
              description: 'should authorize if $targetUserRole can be deleted when calling authorizeDeleteUser',
              currentUser: currentUser,
              targetUser: targetUser,
              verify: (bloc) {
                expect(bloc.authorizeDeleteUser(targetUser), isA<ActionPolicyResult>());
              },
            );

            blocFixture.test(
              description:
                  'should authorize if email of $targetUserRole can be updated when calling authorizeUpdateEmail',
              currentUser: currentUser,
              targetUser: targetUser,
              verify: (bloc) {
                expect(bloc.authorizeUpdateEmail(targetUser), isA<ActionPolicyResult>());
              },
            );

            blocFixture.test(
              description:
                  'should authorize if password of $targetUserRole can be updated when calling authorizeUpdatePassword',
              currentUser: currentUser,
              targetUser: targetUser,
              verify: (bloc) {
                expect(bloc.authorizeUpdatePassword(targetUser), isA<ActionPolicyResult>());
              },
            );
          },
        );
      });

      group('{Validation Methods}', () {
        UserTestRunner.forEachUserPair(
          users: allMockUserPairs,
          onUserPairCase: (currentUser, targetUser) {
            group('{Email Validation}', () {
              blocFixture.test(
                description: 'should validate valid email when calling validateEmail',
                currentUser: currentUser,
                targetUser: targetUser,
                verify: (bloc) {
                  expect(bloc.validateEmail(mockValidEmail), isA<Valid>());
                },
              );

              blocFixture.test(
                description: 'should not validate invalid email when calling validateEmail',
                currentUser: currentUser,
                targetUser: targetUser,
                verify: (bloc) {
                  expect(bloc.validateEmail(mockInvalidEmail), isA<Invalid>());
                },
              );
            });
            group('{Password Validation}', () {
              blocFixture.test(
                description: 'should validate valid password  when calling validatePassword',
                currentUser: currentUser,
                targetUser: targetUser,
                verify: (bloc) {
                  expect(bloc.validatePassword(mockValidPassword), isA<Valid>());
                },
              );

              blocFixture.test(
                description: 'should not validate invalid password when calling validatePassword',
                currentUser: currentUser,
                targetUser: targetUser,
                verify: (bloc) {
                  expect(bloc.validatePassword(mockTooShortPassword), isA<Invalid>());
                },
              );
            });
          },
        );
      });
    });
    group('{Events}', () {
      group('{FetchUsersRequested Event}', () {
        UserTestRunner.forEachUserPairWithPolicy(
          policy: ViewUserPolicy(),
          users: allMockUserPairs,
          onAuthorized: (currentUser, targetUser) {
            blocFixture.test(
              description:
                  'fetched users should include users with role ${targetUser.role.name} when FetchUsersRequested is added',
              currentUser: currentUser,
              targetUser: targetUser,
              stub: () => when(() => blocFixture.mockRepository.users).thenAnswer((_) async => allMockUserPairs),
              act: (bloc) => bloc.add(FetchUsersRequested()),
              expect: () => [isA<UserAdministrationViewLoading>(), isA<UserAdministrationViewLoaded>()],
              verify: (bloc) {
                final state = bloc.state;
                expect(state, isA<UserAdministrationViewLoaded>());
                if (state is UserAdministrationViewLoaded) {
                  expect(state.users.contains(targetUser), isTrue);
                }
              },
            );
            blocFixture.test(
              description: 'fetched users should emit failure when repo throws on FetchUsersRequested',
              currentUser: currentUser,
              targetUser: targetUser,
              stub: () => when(() => blocFixture.mockRepository.users).thenThrow(Exception('fetch error')),
              act: (bloc) => bloc.add(FetchUsersRequested()),
              expect: () => [isA<UserAdministrationViewLoading>(), isA<UserAdministrationViewFailure>()],
              verify: (bloc) {
                expect(bloc.state, isA<UserAdministrationViewFailure>());
              },
            );
          },
          onUnauthorized: (currentUser, targetUser, _) {
            blocFixture.test(
              description:
                  'fetched users should not include users with role ${targetUser.role.name} when FetchUsersRequested is added',
              currentUser: currentUser,
              targetUser: targetUser,
              stub: () => when(() => blocFixture.mockRepository.users).thenAnswer((_) async => allMockUserPairs),
              act: (bloc) => bloc.add(FetchUsersRequested()),
              expect: () => [isA<UserAdministrationViewLoading>(), isA<UserAdministrationViewLoaded>()],
              verify: (bloc) {
                final state = bloc.state;
                expect(state, isA<UserAdministrationViewLoaded>());
                if (state is UserAdministrationViewLoaded) {
                  expect(state.users.contains(targetUser), isFalse);
                }
              },
            );
          },
        );
      });
      group('{DeleteUserRequested Event}', () {
        UserTestRunner.forEachUserPairWithPolicy(
          policy: DeleteUserPolicy(),
          users: allMockUserPairs,
          onAuthorized: (currentUser, targetUser) {
            final isDeletingSelf = currentUser.isSameAs(targetUser);

            blocFixture.testPresentation(
              description: 'should delete user when DeleteUserRequested is added',
              currentUser: currentUser,
              targetUser: targetUser,
              stub: () =>
                  when(() => blocFixture.mockRepository.delete(userId: targetUser.userId)).thenAnswer((_) async {}),
              event: DeleteUserRequested(targetUser: targetUser),
              expectPresentation: () => isDeletingSelf ? [isA<DeleteSelfSuccess>()] : [isA<DeleteUserSuccess>()],
              verify: (bloc) => verify(() => blocFixture.mockRepository.delete(userId: targetUser.userId)).called(1),
            );

            blocFixture.testPresentation(
              description: 'should emit failure when repo throws on DeleteUserRequested',
              currentUser: currentUser,
              targetUser: targetUser,
              stub: () => when(
                () => blocFixture.mockRepository.delete(userId: targetUser.userId),
              ).thenThrow(Exception('delete error')),
              event: DeleteUserRequested(targetUser: targetUser),
              expectPresentation: () => [isA<DeleteUserFailure>()],
              verify: (bloc) {},
            );
          },
          onUnauthorized: (currentUser, targetUser, _) {
            blocFixture.testPresentation(
              description: 'should not delete user when DeleteUserRequested is added',
              currentUser: currentUser,
              targetUser: targetUser,
              stub: () =>
                  when(() => blocFixture.mockRepository.delete(userId: targetUser.userId)).thenAnswer((_) async {}),
              event: DeleteUserRequested(targetUser: targetUser),
              expectPresentation: () => [isA<DeleteUserFailure>()],
              verify: (bloc) => verifyNever(() => blocFixture.mockRepository.delete(userId: targetUser.userId)),
            );
          },
        );
      });

      group('{UpdateUserEmailRequested Event}', () {
        UserTestRunner.forEachUserPairWithPolicy(
          policy: UpdateUserEmailPolicy(),
          users: allMockUserPairs,
          onAuthorized: (currentUser, targetUser) {
            blocFixture.testPresentation(
              description: 'should update user email with valid new email when UpdateUserEmailRequested is added',
              currentUser: currentUser,
              targetUser: targetUser,
              stub: () => when(
                () => blocFixture.mockRepository.updateEmail(userId: targetUser.userId, newEmail: mockValidEmail),
              ).thenAnswer((_) async {}),
              event: UpdateUserEmailRequested(targetUser: targetUser, newEmail: mockValidEmail),
              expectPresentation: () => [isA<UpdateUserEmailSuccess>()],
              verify: (bloc) => verify(
                () => blocFixture.mockRepository.updateEmail(userId: targetUser.userId, newEmail: mockValidEmail),
              ).called(1),
            );
            blocFixture.testPresentation(
              description: 'should emit failure when repo throws on UpdateUserEmailRequested',
              currentUser: currentUser,
              targetUser: targetUser,
              stub: () => when(
                () => blocFixture.mockRepository.updateEmail(userId: targetUser.userId, newEmail: mockValidEmail),
              ).thenThrow(Exception('update email error')),
              event: UpdateUserEmailRequested(targetUser: targetUser, newEmail: mockValidEmail),
              expectPresentation: () => [isA<UpdateUserEmailFailure>()],
              verify: (bloc) {},
            );
            blocFixture.testPresentation(
              description: 'should not update user email with invalid new email when UpdateUserEmailRequested is added',
              currentUser: currentUser,
              targetUser: targetUser,
              stub: () => when(
                () => blocFixture.mockRepository.updateEmail(userId: targetUser.userId, newEmail: mockInvalidEmail),
              ).thenAnswer((_) async {}),
              event: UpdateUserEmailRequested(targetUser: targetUser, newEmail: mockInvalidEmail),
              expectPresentation: () => [isA<UpdateUserEmailInvalid>()],
              verify: (bloc) => verifyNever(
                () => blocFixture.mockRepository.updateEmail(userId: targetUser.userId, newEmail: mockInvalidEmail),
              ),
            );
          },
          onUnauthorized: (currentUser, targetUser, _) {
            for (final newEmail in [mockValidEmail, mockInvalidEmail]) {
              blocFixture.testPresentation(
                description: 'should not update user email with any new email when UpdateUserEmailRequested is added',
                currentUser: currentUser,
                targetUser: targetUser,
                stub: () => when(
                  () => blocFixture.mockRepository.updateEmail(userId: targetUser.userId, newEmail: newEmail),
                ).thenAnswer((_) async {}),
                event: UpdateUserEmailRequested(targetUser: targetUser, newEmail: newEmail),
                expectPresentation: () => [anyOf(isA<UpdateUserEmailInvalid>(), isA<UpdateUserEmailFailure>())],
                verify: (bloc) => verifyNever(
                  () => blocFixture.mockRepository.updateEmail(userId: targetUser.userId, newEmail: newEmail),
                ),
              );
            }
          },
        );
      });

      group('{UpdateUserPasswordRequested Event}', () {
        UserTestRunner.forEachUserPairWithPolicy(
          policy: UpdateUserPasswordPolicy(),
          users: allMockUserPairs,
          onAuthorized: (currentUser, targetUser) {
            blocFixture.testPresentation(
              description:
                  'should update user password with valid new password when UpdateUserPasswordRequested is added',
              currentUser: currentUser,
              targetUser: targetUser,
              stub: () => when(
                () => blocFixture.mockRepository.updatePassword(
                  userId: targetUser.userId,
                  newPassword: mockValidPassword,
                ),
              ).thenAnswer((_) async {}),
              event: UpdateUserPasswordRequested(targetUser: targetUser, newPassword: mockValidPassword),
              expectPresentation: () => [isA<UpdateUserPasswordSuccess>()],
              verify: (bloc) => verify(
                () => blocFixture.mockRepository.updatePassword(
                  userId: targetUser.userId,
                  newPassword: mockValidPassword,
                ),
              ).called(1),
            );
            blocFixture.testPresentation(
              description: 'should emit failure when repo throws on UpdateUserPasswordRequested',
              currentUser: currentUser,
              targetUser: targetUser,
              stub: () => when(
                () => blocFixture.mockRepository.updatePassword(
                  userId: targetUser.userId,
                  newPassword: mockValidPassword,
                ),
              ).thenThrow(Exception('update password error')),
              event: UpdateUserPasswordRequested(targetUser: targetUser, newPassword: mockValidPassword),
              expectPresentation: () => [isA<UpdateUserPasswordFailure>()],
              verify: (bloc) {},
            );
            blocFixture.testPresentation(
              description:
                  'should not update user password with invalid new password when UpdateUserPasswordRequested is added',
              currentUser: currentUser,
              targetUser: targetUser,
              stub: () => when(
                () => blocFixture.mockRepository.updatePassword(
                  userId: targetUser.userId,
                  newPassword: mockTooShortPassword,
                ),
              ).thenAnswer((_) async {}),
              event: UpdateUserPasswordRequested(targetUser: targetUser, newPassword: mockTooShortPassword),
              expectPresentation: () => [isA<UpdateUserPasswordInvalid>()],
              verify: (bloc) => verifyNever(
                () => blocFixture.mockRepository.updatePassword(
                  userId: targetUser.userId,
                  newPassword: mockTooShortPassword,
                ),
              ),
            );
          },
          onUnauthorized: (currentUser, targetUser, _) {
            for (final newPassword in [mockValidPassword, mockTooShortPassword]) {
              blocFixture.testPresentation(
                description:
                    'should not update user password with any new password when UpdateUserPasswordRequested is added',
                currentUser: currentUser,
                targetUser: targetUser,
                stub: () => when(
                  () => blocFixture.mockRepository.updatePassword(userId: targetUser.userId, newPassword: newPassword),
                ).thenAnswer((_) async {}),
                event: UpdateUserPasswordRequested(targetUser: targetUser, newPassword: newPassword),
                expectPresentation: () => [anyOf(isA<UpdateUserPasswordInvalid>(), isA<UpdateUserPasswordFailure>())],
                verify: (bloc) => verifyNever(
                  () => blocFixture.mockRepository.updatePassword(userId: targetUser.userId, newPassword: newPassword),
                ),
              );
            }
          },
        );
      });
    });
  });
}
