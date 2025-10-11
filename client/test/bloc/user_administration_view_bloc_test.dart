import 'dart:async';

import 'package:bloc_presentation_test/bloc_presentation_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:client/presentation/views/user_administration_view/blocs/users_view_bloc/user_administration_view_bloc.dart';
import 'package:domain/entities/admin.dart';
import 'package:domain/entities/analyst.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:domain/repositories/user_repository.dart' as domain;
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/password.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'user_administration_view/mock_user_administration_view_bloc_factory.dart';

late MockUserAdministrationViewBlocFactory mockFactory;
late UserAdministrationViewBloc mockBloc;
late domain.UserRepository mockRepo;

final _user = User(
  userId: UserId("user_id_1"),
  email: Email('user_email_11@example.com'),
);

final _otherUser = User(
  userId: UserId("user_id_2"),
  email: Email('user_email_12@example.com'),
);

final _admin = Admin(
  userId: UserId("admin_id_1"),
  email: Email('admin_email_1@example.com'),
);

final _otherAdmin = Admin(
  userId: UserId("admin_id_2"),
  email: Email('admin_email_2@example.com'),
);

final _analyst = Analyst(
  userId: UserId("analyst_id_1"),
  email: Email('analyst_email_1@example.com'),
);

final _otherAnalyst = Analyst(
  userId: UserId("analyst_id_2"),
  email: Email('analyst_email_2@example.com'),
);

final _users = [
  _user,
  _otherUser,
  _admin,
  _otherAdmin,
  _analyst,
  _otherAnalyst,
];

Email validEmail = Email('new_email@example.com');
Email invalidEmail = Email('invalid_email');

Password validPassword = PasswordValidationPolicy.generatePassword();
Password invalidPassword = Password('short');

void _setupMockBloc({required User currentUser}) {
  mockFactory = MockUserAdministrationViewBlocFactory(currentUser: currentUser);
  mockBloc = mockFactory.mockBloc;
  mockRepo = mockFactory.mockServiceRepository;
}

void _initializeBlocStateTest({required User currentUser}) {
  blocTest<UserAdministrationViewBloc, UserAdministrationViewState>(
    'should initialize with expected state',
    setUp: () => _setupMockBloc(currentUser: currentUser),
    build: () => mockBloc,
    verify: (mockBloc) =>
        expect(mockBloc.state, isA<UserAdministrationViewInitial>()),
  );
}

void _methodTest({
  required String description,
  required User currentUser,
  required FutureOr<void> Function(UserAdministrationViewBloc) verify,
}) {
  blocTest<UserAdministrationViewBloc, UserAdministrationViewState>(
    description,
    setUp: () => _setupMockBloc(currentUser: currentUser),
    build: () => mockBloc,
    verify: verify,
  );
}

void _fetchUsersTest({
  required String description,
  required User currentUser,
  required FutureOr<void> Function(UserAdministrationViewBloc) verify,
}) {
  blocTest<UserAdministrationViewBloc, UserAdministrationViewState>(
    description,
    setUp: () {
      _setupMockBloc(currentUser: currentUser);
      when(() => mockRepo.users).thenAnswer((_) async => _users);
    },
    build: () => mockBloc,
    act: (bloc) => bloc.add(FetchUsersRequested()),
    expect: () => [
      isA<UserAdministrationViewLoading>(),
      isA<UserAdministrationViewLoaded>(),
    ],
    verify: (mockBloc) => verify,
  );
}

void _deleteUserTest({
  required String description,
  required User currentUser,
  required User targetUser,
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
      _setupMockBloc(currentUser: currentUser);
      when(
        () => mockRepo.delete(userId: targetUser.userId),
      ).thenAnswer((_) async {});
    },
    build: () => mockBloc,
    act: (bloc) => bloc.add(DeleteUserRequested(targetUser: targetUser)),
    expectPresentation: expectPresentation,
    verify: verify,
  );
}

void _updateUserEmailTest({
  required String description,
  required User currentUser,
  required User targetUser,
  required Email newEmail,
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
      _setupMockBloc(currentUser: currentUser);

      when(
        () =>
            mockRepo.updateEmail(userId: targetUser.userId, newEmail: newEmail),
      ).thenAnswer((_) async {});
    },
    build: () => mockBloc,
    act: (bloc) => bloc.add(
      UpdateUserEmailRequested(targetUser: targetUser, newEmail: newEmail),
    ),
    expectPresentation: expectPresentation,
    verify: verify,
  );
}

void _updateUserPasswordTest({
  required String description,
  required User currentUser,
  required User targetUser,
  required Password newPassword,
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
      _setupMockBloc(currentUser: currentUser);

      when(
        () => mockRepo.updatePassword(
          userId: targetUser.userId,
          newPassword: newPassword,
        ),
      ).thenAnswer((_) async {});
    },
    build: () => mockBloc,
    act: (bloc) => bloc.add(
      UpdateUserPasswordRequested(
        targetUser: targetUser,
        newPassword: newPassword,
      ),
    ),
    expectPresentation: expectPresentation,
    verify: verify,
  );
}

void main() {
  tearDown(() {
    mockFactory.dispose();
  });

  group('UserAdministrationViewBloc', () {
    for (final currentUser in _users) {
      _setupMockBloc(currentUser: currentUser);
      group('{Initialization}', () {
        _initializeBlocStateTest(currentUser: currentUser);
      });
      for (final targetUser in _users) {
        final canViewUser = mockBloc.userAdministrationService.viewUserPolicy
            .authorize(currentUser, targetUser);

        final canDeleteUser = mockBloc
            .userAdministrationService
            .deleteUserPolicy
            .authorize(currentUser, targetUser);

        final canUpdateEmail = mockBloc
            .userAdministrationService
            .updateUserEmailPolicy
            .authorize(currentUser, targetUser);

        final canUpdatePassword = mockBloc
            .userAdministrationService
            .updateUserPasswordPolicy
            .authorize(currentUser, targetUser);

        final validEmailValidation = mockBloc
            .userAdministrationService
            .emailValidationPolicy
            .validate(validEmail);

        final invalidEmailValidation = mockBloc
            .userAdministrationService
            .emailValidationPolicy
            .validate(invalidEmail);

        final validPasswordValidation = mockBloc
            .userAdministrationService
            .passwordValidationPolicy
            .validate(validPassword);

        final invalidPasswordValidation = mockBloc
            .userAdministrationService
            .passwordValidationPolicy
            .validate(invalidPassword);

        final currentUserRole = '{${currentUser.role.name}}';
        final targetUserRole = '{${targetUser.role.name}}';
        const should = '{Should}';
        const shouldNot = '{Should Not}';

        group(
          currentUser.isSameAs(targetUser)
              ? '$currentUserRole acting on self'
              : '$currentUserRole acting on $targetUserRole',
          () {
            group('{Public Methods}', () {
              group('{Authorization Methods}', () {
                _methodTest(
                  description:
                      '$should authorize if $targetUserRole can be deleted when calling authorizeDeleteUser',
                  currentUser: currentUser,
                  verify: (mockBloc) {
                    expect(
                      mockBloc.authorizeDeleteUser(targetUser),
                      equals(canDeleteUser),
                    );
                  },
                );

                _methodTest(
                  description:
                      '$should authorize if email of $targetUserRole can be updated when calling authorizeUpdateEmail',
                  currentUser: currentUser,
                  verify: (mockBloc) {
                    expect(
                      mockBloc.authorizeUpdateEmail(targetUser),
                      equals(canUpdateEmail),
                    );
                  },
                );

                _methodTest(
                  description:
                      '$should authorize if password of $targetUserRole can be updated when calling authorizeUpdatePassword',
                  currentUser: currentUser,
                  verify: (mockBloc) {
                    expect(
                      mockBloc.authorizeUpdatePassword(targetUser),
                      equals(canUpdatePassword),
                    );
                  },
                );
              });

              group('{Validation Methods}', () {
                group('{Email Validation}', () {
                  _methodTest(
                    description:
                        '$should validate valid email when calling validateEmail',
                    currentUser: currentUser,
                    verify: (mockBloc) {
                      final emailValidation = mockBloc.validateEmail(
                        validEmail,
                      );

                      expect(emailValidation, equals(validEmailValidation));
                      expect(emailValidation is Valid, isTrue);
                    },
                  );

                  _methodTest(
                    description:
                        '$shouldNot validate invalid email when calling validateEmail',
                    currentUser: currentUser,
                    verify: (mockBloc) {
                      final emailValidation = mockBloc.validateEmail(
                        invalidEmail,
                      );

                      expect(emailValidation, equals(invalidEmailValidation));
                      expect(emailValidation is Invalid, isTrue);
                    },
                  );
                });
                group('{Password Validation}', () {
                  _methodTest(
                    description:
                        '$should validate valid password  when calling validatePassword',
                    currentUser: currentUser,
                    verify: (mockBloc) {
                      final passwordValidation = mockBloc.validatePassword(
                        validPassword,
                      );

                      expect(
                        passwordValidation,
                        equals(validPasswordValidation),
                      );
                      expect(passwordValidation is Valid, isTrue);
                    },
                  );

                  _methodTest(
                    description:
                        '$shouldNot validate invalid password when calling validatePassword',
                    currentUser: currentUser,
                    verify: (mockBloc) {
                      final passwordValidation = mockBloc.validatePassword(
                        invalidPassword,
                      );

                      expect(
                        passwordValidation,
                        equals(invalidPasswordValidation),
                      );
                      expect(passwordValidation is Invalid, isTrue);
                    },
                  );
                });
              });
            });
            group('{Events}', () {
              group('{FetchUsersRequested Event}', () {
                switch (canViewUser) {
                  case Authorized():
                    _fetchUsersTest(
                      description:
                          'fetched users $should include users with role $targetUserRole when FetchUsersRequested is added',
                      currentUser: currentUser,
                      verify: (mockBloc) {
                        final state = mockBloc.state;
                        expect(state, isA<UserAdministrationViewLoaded>());
                        if (state is UserAdministrationViewLoaded) {
                          expect(state.users.contains(targetUser), isTrue);
                        }
                      },
                    );
                  case Unauthorized():
                    _fetchUsersTest(
                      description:
                          'fetched users $shouldNot include users with role $targetUserRole when FetchUsersRequested is added',
                      currentUser: currentUser,
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
                    _deleteUserTest(
                      description:
                          '$should delete user when DeleteUserRequested is added',
                      currentUser: currentUser,
                      targetUser: targetUser,
                      expectPresentation: () => [isA<DeleteUserSuccess>()],
                      verify: (mockBloc) => verify(
                        () => mockRepo.delete(userId: targetUser.userId),
                      ).called(1),
                    );
                  case Unauthorized():
                    _deleteUserTest(
                      description:
                          '$shouldNot delete user when DeleteUserRequested is added',
                      currentUser: currentUser,
                      targetUser: targetUser,
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
                    _updateUserEmailTest(
                      description:
                          '$should update user email with valid new email when UpdateUserEmailRequested is added',
                      currentUser: currentUser,
                      targetUser: targetUser,
                      newEmail: validEmail,
                      expectPresentation: () => [isA<UpdateUserEmailSuccess>()],
                      verify: (mockBloc) => verify(
                        () => mockRepo.updateEmail(
                          userId: targetUser.userId,
                          newEmail: validEmail,
                        ),
                      ).called(1),
                    );
                    _updateUserEmailTest(
                      description:
                          '$shouldNot update user email with invalid new email when UpdateUserEmailRequested is added',
                      currentUser: currentUser,
                      targetUser: targetUser,
                      newEmail: invalidEmail,
                      expectPresentation: () => [isA<UpdateUserEmailInvalid>()],
                      verify: (mockBloc) => verifyNever(
                        () => mockRepo.updateEmail(
                          userId: targetUser.userId,
                          newEmail: invalidEmail,
                        ),
                      ),
                    );
                  case Unauthorized():
                    for (final newEmail in [validEmail, invalidEmail]) {
                      _updateUserEmailTest(
                        description:
                            '$shouldNot update user email with any new email when UpdateUserEmailRequested is added',
                        currentUser: currentUser,
                        targetUser: targetUser,
                        newEmail: newEmail,
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
                    _updateUserPasswordTest(
                      description:
                          '$should update user password with valid new password when UpdateUserPasswordRequested is added',
                      currentUser: currentUser,
                      targetUser: targetUser,
                      newPassword: validPassword,
                      expectPresentation: () => [
                        isA<UpdateUserPasswordSuccess>(),
                      ],
                      verify: (mockBloc) => verify(
                        () => mockRepo.updatePassword(
                          userId: targetUser.userId,
                          newPassword: validPassword,
                        ),
                      ).called(1),
                    );
                    _updateUserPasswordTest(
                      description:
                          '$shouldNot update user password with invalid new password when UpdateUserPasswordRequested is added',
                      currentUser: currentUser,
                      targetUser: targetUser,
                      newPassword: invalidPassword,
                      expectPresentation: () => [
                        isA<UpdateUserPasswordInvalid>(),
                      ],
                      verify: (mockBloc) => verifyNever(
                        () => mockRepo.updatePassword(
                          userId: targetUser.userId,
                          newPassword: invalidPassword,
                        ),
                      ),
                    );
                  case Unauthorized():
                    for (final newPassword in [
                      validPassword,
                      invalidPassword,
                    ]) {
                      _updateUserPasswordTest(
                        description:
                            '$shouldNot update user password with any new password when UpdateUserPasswordRequested is added',
                        currentUser: currentUser,
                        targetUser: targetUser,
                        newPassword: newPassword,
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
