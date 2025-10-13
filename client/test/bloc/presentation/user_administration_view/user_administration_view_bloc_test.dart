import 'dart:async';

import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:client/presentation/views/user_administration_view/blocs/users_view_bloc/user_administration_view_bloc.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:domain/repositories/user_repository.dart' as domain;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../utils/mock_user_credentials.dart';
import '../../utils/mock_users.dart';

import '../../bloc_test_context.dart';
import 'mock_user_administration_view_bloc_factory.dart';

final blocTestContext =
    BlocTestContext<
      User,
      MockUserAdministrationViewBlocFactory,
      UserAdministrationViewBloc,
      domain.UserRepository
    >(
      factoryBuilder: (currentUser) =>
          MockUserAdministrationViewBlocFactory(currentUser: currentUser),
      getBloc: (factory) => factory.mockBloc,
      getRepo: (factory) => factory.mockServiceRepository,
    );

void _blocTest({
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
      blocTestContext.setup(currentUser);
      stub?.call();
    },
    build: () => blocTestContext.bloc,
    act: act,
    expect: expect,
    verify: verify,
  );
}

void _blocPresentationTest({
  required String description,
  required User currentUser,
  required User targetUser,
  void Function()? stub,
  required UserAdministrationViewEvent event,
  required dynamic Function() expectPresentation,
  required FutureOr<void> Function(UserAdministrationViewBloc) verify,
}) {
  blocPresentationTest<
    UserAdministrationViewBloc,
    UserAdministrationViewState,
    UserAdministrationViewEvent
  >(
    description,
    setUp: () {
      blocTestContext.setup(currentUser);
      stub?.call();
    },
    build: () => blocTestContext.bloc,
    act: (bloc) => bloc.add(event),
    expectPresentation: expectPresentation,
    verify: verify,
  );
}

const should = '{Should}';
const shouldNot = '{Should Not}';

void main() {
  tearDown(() {
    blocTestContext.factory.dispose();
  });

  group('UserAdministrationViewBloc', () {
    for (final currentUser in mockUsers) {
      final currentUserRole = '{${currentUser.role.name}}';

      blocTestContext.setup(currentUser);

      for (final targetUser in mockUsers) {
        final targetUserRole = '{${targetUser.role.name}}';

        group('{Initialization}', () {
          _blocTest(
            description: 'should initialize with expected state',
            currentUser: currentUser,
            targetUser: targetUser,
            verify: (bloc) =>
                expect(bloc.state, isA<UserAdministrationViewInitial>()),
          );
        });

        group(
          currentUser.isSameAs(targetUser)
              ? '$currentUserRole acting on self'
              : '$currentUserRole acting on $targetUserRole',
          () {
            group('{Public Methods}', () {
              group('{Authorization Methods}', () {
                _blocTest(
                  description:
                      '$should authorize if $targetUserRole can be deleted when calling authorizeDeleteUser',
                  currentUser: currentUser,
                  targetUser: targetUser,
                  verify: (bloc) {
                    expect(
                      bloc.authorizeDeleteUser(targetUser),
                      isA<ActionPolicyResult>(),
                    );
                  },
                );

                _blocTest(
                  description:
                      '$should authorize if email of $targetUserRole can be updated when calling authorizeUpdateEmail',
                  currentUser: currentUser,
                  targetUser: targetUser,
                  verify: (bloc) {
                    expect(
                      bloc.authorizeUpdateEmail(targetUser),
                      isA<ActionPolicyResult>(),
                    );
                  },
                );

                _blocTest(
                  description:
                      '$should authorize if password of $targetUserRole can be updated when calling authorizeUpdatePassword',
                  currentUser: currentUser,
                  targetUser: targetUser,
                  verify: (bloc) {
                    expect(
                      bloc.authorizeUpdatePassword(targetUser),
                      isA<ActionPolicyResult>(),
                    );
                  },
                );
              });

              group('{Validation Methods}', () {
                group('{Email Validation}', () {
                  _blocTest(
                    description:
                        '$should validate valid email when calling validateEmail',
                    currentUser: currentUser,
                    targetUser: targetUser,
                    verify: (bloc) {
                      expect(bloc.validateEmail(mockValidEmail), isA<Valid>());
                    },
                  );

                  _blocTest(
                    description:
                        '$shouldNot validate invalid email when calling validateEmail',
                    currentUser: currentUser,
                    targetUser: targetUser,
                    verify: (bloc) {
                      expect(
                        bloc.validateEmail(mockInvalidEmail),
                        isA<Invalid>(),
                      );
                    },
                  );
                });
                group('{Password Validation}', () {
                  _blocTest(
                    description:
                        '$should validate valid password  when calling validatePassword',
                    currentUser: currentUser,
                    targetUser: targetUser,
                    verify: (bloc) {
                      expect(
                        bloc.validatePassword(mockValidPassword),
                        isA<Valid>(),
                      );
                    },
                  );

                  _blocTest(
                    description:
                        '$shouldNot validate invalid password when calling validatePassword',
                    currentUser: currentUser,
                    targetUser: targetUser,
                    verify: (bloc) {
                      expect(
                        bloc.validatePassword(mockInvalidPassword),
                        isA<Invalid>(),
                      );
                    },
                  );
                });
              });
            });
            group('{Events}', () {
              group('{FetchUsersRequested Event}', () {
                final canViewUser = blocTestContext
                    .bloc
                    .userAdministrationService
                    .viewUserPolicy
                    .authorize(currentUser, targetUser);
                switch (canViewUser) {
                  case Authorized():
                    _blocTest(
                      description:
                          'fetched users $should include users with role $targetUserRole when FetchUsersRequested is added',
                      currentUser: currentUser,
                      targetUser: targetUser,
                      stub: () => when(
                        () => blocTestContext.repo.users,
                      ).thenAnswer((_) async => mockUsers),
                      act: (bloc) => bloc.add(FetchUsersRequested()),
                      expect: () => [
                        isA<UserAdministrationViewLoading>(),
                        isA<UserAdministrationViewLoaded>(),
                      ],
                      verify: (bloc) {
                        final state = bloc.state;
                        expect(state, isA<UserAdministrationViewLoaded>());
                        if (state is UserAdministrationViewLoaded) {
                          expect(state.users.contains(targetUser), isTrue);
                        }
                      },
                    );
                    _blocTest(
                      description:
                          'fetched users $should emit failure when repo throws on FetchUsersRequested',
                      currentUser: currentUser,
                      targetUser: targetUser,
                      stub: () => when(
                        () => blocTestContext.repo.users,
                      ).thenThrow(Exception('fetch error')),
                      act: (bloc) => bloc.add(FetchUsersRequested()),
                      expect: () => [
                        isA<UserAdministrationViewLoading>(),
                        isA<UserAdministrationViewFailure>(),
                      ],
                      verify: (bloc) {
                        expect(
                          bloc.state,
                          isA<UserAdministrationViewFailure>(),
                        );
                      },
                    );
                  case Unauthorized():
                    _blocTest(
                      description:
                          'fetched users $shouldNot include users with role $targetUserRole when FetchUsersRequested is added',
                      currentUser: currentUser,
                      targetUser: targetUser,
                      stub: () => when(
                        () => blocTestContext.repo.users,
                      ).thenAnswer((_) async => mockUsers),
                      act: (bloc) => bloc.add(FetchUsersRequested()),
                      expect: () => [
                        isA<UserAdministrationViewLoading>(),
                        isA<UserAdministrationViewLoaded>(),
                      ],
                      verify: (bloc) {
                        final state = bloc.state;
                        expect(state, isA<UserAdministrationViewLoaded>());
                        if (state is UserAdministrationViewLoaded) {
                          expect(state.users.contains(targetUser), isFalse);
                        }
                      },
                    );
                }
              });

              group('{DeleteUserRequested Event}', () {
                final canDeleteUser = blocTestContext
                    .bloc
                    .userAdministrationService
                    .deleteUserPolicy
                    .authorize(currentUser, targetUser);
                switch (canDeleteUser) {
                  case Authorized():
                    _blocPresentationTest(
                      description:
                          '$should delete user when DeleteUserRequested is added',
                      currentUser: currentUser,
                      targetUser: targetUser,
                      stub: () => when(
                        () => blocTestContext.repo.delete(
                          userId: targetUser.userId,
                        ),
                      ).thenAnswer((_) async {}),
                      event: DeleteUserRequested(targetUser: targetUser),
                      expectPresentation: () => [isA<DeleteUserSuccess>()],
                      verify: (bloc) => verify(
                        () => blocTestContext.repo.delete(
                          userId: targetUser.userId,
                        ),
                      ).called(1),
                    );
                    _blocPresentationTest(
                      description:
                          '$should emit failure when repo throws on DeleteUserRequested',
                      currentUser: currentUser,
                      targetUser: targetUser,
                      stub: () => when(
                        () => blocTestContext.repo.delete(
                          userId: targetUser.userId,
                        ),
                      ).thenThrow(Exception('delete error')),
                      event: DeleteUserRequested(targetUser: targetUser),
                      expectPresentation: () => [isA<DeleteUserFailure>()],
                      verify: (bloc) {},
                    );
                  case Unauthorized():
                    _blocPresentationTest(
                      description:
                          '$shouldNot delete user when DeleteUserRequested is added',
                      currentUser: currentUser,
                      targetUser: targetUser,
                      stub: () => when(
                        () => blocTestContext.repo.delete(
                          userId: targetUser.userId,
                        ),
                      ).thenAnswer((_) async {}),
                      event: DeleteUserRequested(targetUser: targetUser),
                      expectPresentation: () => [isA<DeleteUserFailure>()],
                      verify: (bloc) => verifyNever(
                        () => blocTestContext.repo.delete(
                          userId: targetUser.userId,
                        ),
                      ),
                    );
                }
              });

              group('{UpdateUserEmailRequested Event}', () {
                final canUpdateEmail = blocTestContext
                    .bloc
                    .userAdministrationService
                    .updateUserEmailPolicy
                    .authorize(currentUser, targetUser);
                switch (canUpdateEmail) {
                  case Authorized():
                    _blocPresentationTest(
                      description:
                          '$should update user email with valid new email when UpdateUserEmailRequested is added',
                      currentUser: currentUser,
                      targetUser: targetUser,
                      stub: () => when(
                        () => blocTestContext.repo.updateEmail(
                          userId: targetUser.userId,
                          newEmail: mockValidEmail,
                        ),
                      ).thenAnswer((_) async {}),
                      event: UpdateUserEmailRequested(
                        targetUser: targetUser,
                        newEmail: mockValidEmail,
                      ),
                      expectPresentation: () => [isA<UpdateUserEmailSuccess>()],
                      verify: (bloc) => verify(
                        () => blocTestContext.repo.updateEmail(
                          userId: targetUser.userId,
                          newEmail: mockValidEmail,
                        ),
                      ).called(1),
                    );
                    _blocPresentationTest(
                      description:
                          '$should emit failure when repo throws on UpdateUserEmailRequested',
                      currentUser: currentUser,
                      targetUser: targetUser,
                      stub: () => when(
                        () => blocTestContext.repo.updateEmail(
                          userId: targetUser.userId,
                          newEmail: mockValidEmail,
                        ),
                      ).thenThrow(Exception('update email error')),
                      event: UpdateUserEmailRequested(
                        targetUser: targetUser,
                        newEmail: mockValidEmail,
                      ),
                      expectPresentation: () => [isA<UpdateUserEmailFailure>()],
                      verify: (bloc) {},
                    );
                    _blocPresentationTest(
                      description:
                          '$shouldNot update user email with invalid new email when UpdateUserEmailRequested is added',
                      currentUser: currentUser,
                      targetUser: targetUser,
                      stub: () => when(
                        () => blocTestContext.repo.updateEmail(
                          userId: targetUser.userId,
                          newEmail: mockInvalidEmail,
                        ),
                      ).thenAnswer((_) async {}),
                      event: UpdateUserEmailRequested(
                        targetUser: targetUser,
                        newEmail: mockInvalidEmail,
                      ),
                      expectPresentation: () => [isA<UpdateUserEmailInvalid>()],
                      verify: (bloc) => verifyNever(
                        () => blocTestContext.repo.updateEmail(
                          userId: targetUser.userId,
                          newEmail: mockInvalidEmail,
                        ),
                      ),
                    );
                  case Unauthorized():
                    for (final newEmail in [mockValidEmail, mockInvalidEmail]) {
                      _blocPresentationTest(
                        description:
                            '$shouldNot update user email with any new email when UpdateUserEmailRequested is added',
                        currentUser: currentUser,
                        targetUser: targetUser,
                        stub: () => when(
                          () => blocTestContext.repo.updateEmail(
                            userId: targetUser.userId,
                            newEmail: newEmail,
                          ),
                        ).thenAnswer((_) async {}),
                        event: UpdateUserEmailRequested(
                          targetUser: targetUser,
                          newEmail: newEmail,
                        ),
                        expectPresentation: () => [
                          anyOf(
                            isA<UpdateUserEmailInvalid>(),
                            isA<UpdateUserEmailFailure>(),
                          ),
                        ],
                        verify: (bloc) => verifyNever(
                          () => blocTestContext.repo.updateEmail(
                            userId: targetUser.userId,
                            newEmail: newEmail,
                          ),
                        ),
                      );
                    }
                }
              });

              group('{UpdateUserPasswordRequested Event}', () {
                final canUpdatePassword = blocTestContext
                    .bloc
                    .userAdministrationService
                    .updateUserPasswordPolicy
                    .authorize(currentUser, targetUser);
                switch (canUpdatePassword) {
                  case Authorized():
                    _blocPresentationTest(
                      description:
                          '$should update user password with valid new password when UpdateUserPasswordRequested is added',
                      currentUser: currentUser,
                      targetUser: targetUser,
                      stub: () => when(
                        () => blocTestContext.repo.updatePassword(
                          userId: targetUser.userId,
                          newPassword: mockValidPassword,
                        ),
                      ).thenAnswer((_) async {}),
                      event: UpdateUserPasswordRequested(
                        targetUser: targetUser,
                        newPassword: mockValidPassword,
                      ),
                      expectPresentation: () => [
                        isA<UpdateUserPasswordSuccess>(),
                      ],
                      verify: (bloc) => verify(
                        () => blocTestContext.repo.updatePassword(
                          userId: targetUser.userId,
                          newPassword: mockValidPassword,
                        ),
                      ).called(1),
                    );
                    _blocPresentationTest(
                      description:
                          '$should emit failure when repo throws on UpdateUserPasswordRequested',
                      currentUser: currentUser,
                      targetUser: targetUser,
                      stub: () => when(
                        () => blocTestContext.repo.updatePassword(
                          userId: targetUser.userId,
                          newPassword: mockValidPassword,
                        ),
                      ).thenThrow(Exception('update password error')),
                      event: UpdateUserPasswordRequested(
                        targetUser: targetUser,
                        newPassword: mockValidPassword,
                      ),
                      expectPresentation: () => [
                        isA<UpdateUserPasswordFailure>(),
                      ],
                      verify: (bloc) {},
                    );
                    _blocPresentationTest(
                      description:
                          '$shouldNot update user password with invalid new password when UpdateUserPasswordRequested is added',
                      currentUser: currentUser,
                      targetUser: targetUser,
                      stub: () => when(
                        () => blocTestContext.repo.updatePassword(
                          userId: targetUser.userId,
                          newPassword: mockInvalidPassword,
                        ),
                      ).thenAnswer((_) async {}),
                      event: UpdateUserPasswordRequested(
                        targetUser: targetUser,
                        newPassword: mockInvalidPassword,
                      ),
                      expectPresentation: () => [
                        isA<UpdateUserPasswordInvalid>(),
                      ],
                      verify: (bloc) => verifyNever(
                        () => blocTestContext.repo.updatePassword(
                          userId: targetUser.userId,
                          newPassword: mockInvalidPassword,
                        ),
                      ),
                    );
                  case Unauthorized():
                    for (final newPassword in [
                      mockValidPassword,
                      mockInvalidPassword,
                    ]) {
                      _blocPresentationTest(
                        description:
                            '$shouldNot update user password with any new password when UpdateUserPasswordRequested is added',
                        currentUser: currentUser,
                        targetUser: targetUser,
                        stub: () => when(
                          () => blocTestContext.repo.updatePassword(
                            userId: targetUser.userId,
                            newPassword: newPassword,
                          ),
                        ).thenAnswer((_) async {}),
                        event: UpdateUserPasswordRequested(
                          targetUser: targetUser,
                          newPassword: newPassword,
                        ),
                        expectPresentation: () => [
                          anyOf(
                            isA<UpdateUserPasswordInvalid>(),
                            isA<UpdateUserPasswordFailure>(),
                          ),
                        ],
                        verify: (bloc) => verifyNever(
                          () => blocTestContext.repo.updatePassword(
                            userId: targetUser.userId,
                            newPassword: newPassword,
                          ),
                        ),
                      );
                    }
                }
              });
            });
          },
        );
      }
    }
  });
}
