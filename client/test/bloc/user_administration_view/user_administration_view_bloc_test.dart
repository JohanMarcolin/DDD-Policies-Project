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

import '../utils/mock_user_credentials.dart';
import '../utils/mock_users.dart';
import 'mock_user_administration_view_bloc_factory.dart';

late MockUserAdministrationViewBlocFactory mockFactory;
late UserAdministrationViewBloc mockBloc;
late domain.UserRepository mockRepo;

late ActionPolicyResult canViewUser;
late ActionPolicyResult canDeleteUser;
late ActionPolicyResult canUpdateEmail;
late ActionPolicyResult canUpdatePassword;

void _setupTestContext({required User currentUser, required User targetUser}) {
  _setupMockBloc(currentUser: currentUser);
  _setupActionAuthorization(currentUser: currentUser, targetUser: targetUser);
}

void _setupMockBloc({required User currentUser}) {
  mockFactory = MockUserAdministrationViewBlocFactory(currentUser: currentUser);
  mockBloc = mockFactory.mockBloc;
  mockRepo = mockFactory.mockServiceRepository;
}

void _setupActionAuthorization({
  required User currentUser,
  required User targetUser,
}) {
  canViewUser = mockBloc.userAdministrationService.viewUserPolicy.authorize(
    currentUser,
    targetUser,
  );

  canDeleteUser = mockBloc.userAdministrationService.deleteUserPolicy.authorize(
    currentUser,
    targetUser,
  );

  canUpdateEmail = mockBloc.userAdministrationService.updateUserEmailPolicy
      .authorize(currentUser, targetUser);

  canUpdatePassword = mockBloc
      .userAdministrationService
      .updateUserPasswordPolicy
      .authorize(currentUser, targetUser);
}

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
      _setupTestContext(currentUser: currentUser, targetUser: targetUser);
      stub?.call();
    },
    build: () => mockBloc,
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
      _setupTestContext(currentUser: currentUser, targetUser: targetUser);
      stub?.call();
    },
    build: () => mockBloc,
    act: (bloc) => bloc.add(event),
    expectPresentation: expectPresentation,
    verify: verify,
  );
}

const should = '{Should}';
const shouldNot = '{Should Not}';

void main() {
  tearDown(() {
    mockFactory.dispose();
  });

  group('UserAdministrationViewBloc', () {
    for (final currentUser in mockUsers) {
      final currentUserRole = '{${currentUser.role.name}}';

      for (final targetUser in mockUsers) {
        final targetUserRole = '{${targetUser.role.name}}';

        _setupTestContext(currentUser: currentUser, targetUser: targetUser);

        group('{Initialization}', () {
          _blocTest(
            description: 'should initialize with expected state',
            currentUser: currentUser,
            targetUser: targetUser,
            verify: (mockBloc) =>
                expect(mockBloc.state, isA<UserAdministrationViewInitial>()),
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
                  verify: (mockBloc) {
                    expect(
                      mockBloc.authorizeDeleteUser(targetUser),
                      isA<ActionPolicyResult>(),
                    );
                  },
                );

                _blocTest(
                  description:
                      '$should authorize if email of $targetUserRole can be updated when calling authorizeUpdateEmail',
                  currentUser: currentUser,
                  targetUser: targetUser,
                  verify: (mockBloc) {
                    expect(
                      mockBloc.authorizeUpdateEmail(targetUser),
                      isA<ActionPolicyResult>(),
                    );
                  },
                );

                _blocTest(
                  description:
                      '$should authorize if password of $targetUserRole can be updated when calling authorizeUpdatePassword',
                  currentUser: currentUser,
                  targetUser: targetUser,
                  verify: (mockBloc) {
                    expect(
                      mockBloc.authorizeUpdatePassword(targetUser),
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
                    verify: (mockBloc) {
                      expect(
                        mockBloc.validateEmail(mockValidEmail),
                        isA<Valid>(),
                      );
                    },
                  );

                  _blocTest(
                    description:
                        '$shouldNot validate invalid email when calling validateEmail',
                    currentUser: currentUser,
                    targetUser: targetUser,
                    verify: (mockBloc) {
                      expect(
                        mockBloc.validateEmail(mockInvalidEmail),
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
                    verify: (mockBloc) {
                      expect(
                        mockBloc.validatePassword(mockValidPassword),
                        isA<Valid>(),
                      );
                    },
                  );

                  _blocTest(
                    description:
                        '$shouldNot validate invalid password when calling validatePassword',
                    currentUser: currentUser,
                    targetUser: targetUser,
                    verify: (mockBloc) {
                      expect(
                        mockBloc.validatePassword(mockInvalidPassword),
                        isA<Invalid>(),
                      );
                    },
                  );
                });
              });
            });
            group('{Events}', () {
              group('{FetchUsersRequested Event}', () {
                switch (canViewUser) {
                  case Authorized():
                    _blocTest(
                      description:
                          'fetched users $should include users with role $targetUserRole when FetchUsersRequested is added',
                      currentUser: currentUser,
                      targetUser: targetUser,
                      stub: () => when(
                        () => mockRepo.users,
                      ).thenAnswer((_) async => mockUsers),
                      act: (bloc) => bloc.add(FetchUsersRequested()),
                      expect: () => [
                        isA<UserAdministrationViewLoading>(),
                        isA<UserAdministrationViewLoaded>(),
                      ],
                      verify: (mockBloc) {
                        final state = mockBloc.state;
                        expect(state, isA<UserAdministrationViewLoaded>());
                        if (state is UserAdministrationViewLoaded) {
                          expect(state.users.contains(targetUser), isTrue);
                        }
                      },
                    );
                  case Unauthorized():
                    _blocTest(
                      description:
                          'fetched users $shouldNot include users with role $targetUserRole when FetchUsersRequested is added',
                      currentUser: currentUser,
                      targetUser: targetUser,
                      stub: () => when(
                        () => mockRepo.users,
                      ).thenAnswer((_) async => mockUsers),
                      act: (bloc) => bloc.add(FetchUsersRequested()),
                      expect: () => [
                        isA<UserAdministrationViewLoading>(),
                        isA<UserAdministrationViewLoaded>(),
                      ],
                      verify: (mockBloc) {
                        final state = mockBloc.state;
                        expect(state, isA<UserAdministrationViewLoaded>());
                        if (state is UserAdministrationViewLoaded) {
                          expect(state.users.contains(targetUser), isFalse);
                        }
                      },
                    );
                }
              });

              group('{DeleteUserRequested Event}', () {
                switch (canDeleteUser) {
                  case Authorized():
                    _blocPresentationTest(
                      description:
                          '$should delete user when DeleteUserRequested is added',
                      currentUser: currentUser,
                      targetUser: targetUser,
                      stub: () => when(
                        () => mockRepo.delete(userId: targetUser.userId),
                      ).thenAnswer((_) async {}),
                      event: DeleteUserRequested(targetUser: targetUser),
                      expectPresentation: () => [isA<DeleteUserSuccess>()],
                      verify: (mockBloc) => verify(
                        () => mockRepo.delete(userId: targetUser.userId),
                      ).called(1),
                    );
                  case Unauthorized():
                    _blocPresentationTest(
                      description:
                          '$shouldNot delete user when DeleteUserRequested is added',
                      currentUser: currentUser,
                      targetUser: targetUser,
                      stub: () => when(
                        () => mockRepo.delete(userId: targetUser.userId),
                      ).thenAnswer((_) async {}),
                      event: DeleteUserRequested(targetUser: targetUser),
                      expectPresentation: () => [isA<DeleteUserFailure>()],
                      verify: (mockBloc) => verifyNever(
                        () => mockRepo.delete(userId: targetUser.userId),
                      ),
                    );
                }
              });

              group('{UpdateUserEmailRequested Event}', () {
                switch (canUpdateEmail) {
                  case Authorized():
                    _blocPresentationTest(
                      description:
                          '$should update user email with valid new email when UpdateUserEmailRequested is added',
                      currentUser: currentUser,
                      targetUser: targetUser,
                      stub: () => when(
                        () => mockRepo.updateEmail(
                          userId: targetUser.userId,
                          newEmail: mockValidEmail,
                        ),
                      ).thenAnswer((_) async {}),
                      event: UpdateUserEmailRequested(
                        targetUser: targetUser,
                        newEmail: mockValidEmail,
                      ),
                      expectPresentation: () => [isA<UpdateUserEmailSuccess>()],
                      verify: (mockBloc) => verify(
                        () => mockRepo.updateEmail(
                          userId: targetUser.userId,
                          newEmail: mockValidEmail,
                        ),
                      ).called(1),
                    );
                    _blocPresentationTest(
                      description:
                          '$shouldNot update user email with invalid new email when UpdateUserEmailRequested is added',
                      currentUser: currentUser,
                      targetUser: targetUser,
                      stub: () => when(
                        () => mockRepo.updateEmail(
                          userId: targetUser.userId,
                          newEmail: mockInvalidEmail,
                        ),
                      ).thenAnswer((_) async {}),
                      event: UpdateUserEmailRequested(
                        targetUser: targetUser,
                        newEmail: mockInvalidEmail,
                      ),
                      expectPresentation: () => [isA<UpdateUserEmailInvalid>()],
                      verify: (mockBloc) => verifyNever(
                        () => mockRepo.updateEmail(
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
                          () => mockRepo.updateEmail(
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
                        verify: (mockBloc) => verifyNever(
                          () => mockRepo.updateEmail(
                            userId: targetUser.userId,
                            newEmail: newEmail,
                          ),
                        ),
                      );
                    }
                }
              });

              group('{UpdateUserPasswordRequested Event}', () {
                switch (canUpdatePassword) {
                  case Authorized():
                    _blocPresentationTest(
                      description:
                          '$should update user password with valid new password when UpdateUserPasswordRequested is added',
                      currentUser: currentUser,
                      targetUser: targetUser,
                      stub: () => when(
                        () => mockRepo.updatePassword(
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
                      verify: (mockBloc) => verify(
                        () => mockRepo.updatePassword(
                          userId: targetUser.userId,
                          newPassword: mockValidPassword,
                        ),
                      ).called(1),
                    );
                    _blocPresentationTest(
                      description:
                          '$shouldNot update user password with invalid new password when UpdateUserPasswordRequested is added',
                      currentUser: currentUser,
                      targetUser: targetUser,
                      stub: () => when(
                        () => mockRepo.updatePassword(
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
                      verify: (mockBloc) => verifyNever(
                        () => mockRepo.updatePassword(
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
                          () => mockRepo.updatePassword(
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
                        verify: (mockBloc) => verifyNever(
                          () => mockRepo.updatePassword(
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
