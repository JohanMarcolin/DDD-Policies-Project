import 'package:client/infrastructure/apis/auth_api.dart';
import 'package:client/infrastructure/auth_bloc/auth_bloc.dart';
import 'package:client/infrastructure/services/auth_token_service.dart';
import 'package:client/presentation/views/user_administration_view/blocs/users_view_bloc/user_administration_view_bloc.dart';
import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:client/presentation/widgets/action_icon.dart';
import 'package:client/presentation/widgets/action_snack_bar_helper.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:domain/repositories/user_repository.dart';
import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../../test/bloc/utils/mock_user_credentials.dart';
import '../../../../../../test/bloc/utils/mock_users.dart';
import '../../../../../utils/extensions/widget_finder_extension.dart';

class MockUserRepository extends Mock implements UserRepository {}

late MockUserRepository mockUserRepository;
late UserAdministrationViewBloc userAdministrationViewBloc;
late User currentUser;
late List<User> targetUsers;

extension on WidgetTester {
  Future<void> renderUpdateUserEmailIcon({
    required User currentUser,
    required User targetUser,
  }) async {
    userAdministrationViewBloc = UserAdministrationViewBloc(
      currentUser: currentUser,
      userAdministrationService: UserAdministrationService(
        userRepository: mockUserRepository,
        viewUserPolicy: ViewUserPolicy(),
        updateUserEmailPolicy: UpdateUserEmailPolicy(),
        updateUserPasswordPolicy: UpdateUserPasswordPolicy(),
        deleteUserPolicy: DeleteUserPolicy(),
        emailValidationPolicy: EmailValidationPolicy(),
        passwordValidationPolicy: PasswordValidationPolicy(),
      ),
    );

    await pumpWidget(
      BlocProvider<UserAdministrationViewBloc>.value(
        value: userAdministrationViewBloc,
        child: MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(
                value: AuthBloc(
                  authApi: AuthApi(authTokenService: AuthTokenService()),
                ),
              ),
              BlocProvider<UserAdministrationViewBloc>.value(
                value: userAdministrationViewBloc,
              ),
            ],
            child: Material(child: UpdateUserEmailIcon(user: targetUser)),
          ),
        ),
      ),
    );
  }
}

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    mockUserRepository = MockUserRepository();
  });

  group('UpdateUserEmailIcon', () {
    for (final currentUser in mockUsers) {
      for (final targetUser in mockUsers) {
        group(
          currentUser.isSameAs(targetUser)
              ? '${currentUser.role.name} acting on self'
              : '${currentUser.role.name} acting on ${targetUser.role.name}',
          () {
            final canUpdateEmail = UpdateUserEmailPolicy().authorize(
              currentUser,
              targetUser,
            );

            switch (canUpdateEmail) {
              case Authorized():
                {
                  group('(update authorized)', () {
                    testWidgets('shows solid action icon', (
                      WidgetTester tester,
                    ) async {
                      await tester.renderUpdateUserEmailIcon(
                        currentUser: currentUser,
                        targetUser: targetUser,
                      );

                      final updateEmailIcon = find.byType(UpdateUserEmailIcon);
                      expect(updateEmailIcon, findsOne);

                      final actionIcon = updateEmailIcon.findDescendant(
                        ActionIcon,
                      );
                      expect(actionIcon, findsOne);
                      final actionIconWidget = tester.widget<ActionIcon>(
                        actionIcon,
                      );

                      expect(actionIconWidget.isGreyedOut, isFalse);
                    });

                    testWidgets('shows dialog when action icon is tapped', (
                      WidgetTester tester,
                    ) async {
                      await tester.renderUpdateUserEmailIcon(
                        currentUser: currentUser,
                        targetUser: targetUser,
                      );

                      final updateEmailIcon = find.byType(UpdateUserEmailIcon);
                      final actionIcon = updateEmailIcon.findDescendant(
                        ActionIcon,
                      );
                      expect(actionIcon, findsOne);

                      await tester.tap(actionIcon);
                      await tester.pumpAndSettle();

                      final updateEmailDialogChild = find.byType(
                        UpdateUserEmailDialogChild,
                      );
                      expect(updateEmailDialogChild, findsOne);
                    });

                    testWidgets('cancel closes dialog', (
                      WidgetTester tester,
                    ) async {
                      await tester.renderUpdateUserEmailIcon(
                        currentUser: currentUser,
                        targetUser: targetUser,
                      );
                      final actionIcon = find.byType(ActionIcon);
                      await tester.tap(actionIcon);
                      await tester.pumpAndSettle();
                      expect(find.byType(UpdateUserEmailDialogChild), findsOne);
                      final cancelButton = find.text('Cancel');
                      await tester.tap(cancelButton);
                      await tester.pumpAndSettle();
                      expect(
                        find.byType(UpdateUserEmailDialogChild),
                        findsNothing,
                      );
                    });

                    testWidgets(
                      'confirm with valid email shows success snackbar and closes dialog',
                      (WidgetTester tester) async {
                        when(
                          () => mockUserRepository.updateEmail(
                            userId: targetUser.userId,
                            newEmail: mockValidEmail,
                          ),
                        ).thenAnswer((_) async => {});

                        await tester.renderUpdateUserEmailIcon(
                          currentUser: currentUser,
                          targetUser: targetUser,
                        );
                        final actionIcon = find.byType(ActionIcon);
                        await tester.tap(actionIcon);
                        await tester.pumpAndSettle();
                        expect(
                          find.byType(UpdateUserEmailDialogChild),
                          findsOne,
                        );
                        final emailField = find.byType(TextField);
                        await tester.enterText(
                          emailField,
                          mockValidEmail.value,
                        );

                        final confirmButton = find.text('Confirm');
                        await tester.tap(confirmButton);
                        await tester.pumpAndSettle();

                        expect(
                          find.byType(UpdateUserEmailDialogChild),
                          findsNothing,
                        );

                        verify(
                          () => mockUserRepository.updateEmail(
                            userId: targetUser.userId,
                            newEmail: mockValidEmail,
                          ),
                        ).called(1);
                        expect(
                          ActionSnackBarHelper.lastMessage,
                          'Email updated successfully',
                        );
                      },
                    );

                    testWidgets(
                      'confirm with invalid email shows error snackbar and keeps dialog open',
                      (WidgetTester tester) async {
                        await tester.renderUpdateUserEmailIcon(
                          currentUser: currentUser,
                          targetUser: targetUser,
                        );

                        final actionIcon = find.byType(ActionIcon);
                        await tester.tap(actionIcon);
                        await tester.pumpAndSettle();
                        expect(
                          find.byType(UpdateUserEmailDialogChild),
                          findsOne,
                        );
                        final emailField = find.byType(TextField);
                        await tester.enterText(
                          emailField,
                          mockInvalidEmail.value,
                        );
                        final confirmButton = find.text('Confirm');
                        await tester.tap(confirmButton);
                        await tester.pumpAndSettle();
                        expect(
                          find.byType(UpdateUserEmailDialogChild),
                          findsOne,
                        );

                        verifyNever(
                          () => mockUserRepository.updateEmail(
                            userId: targetUser.userId,
                            newEmail: mockInvalidEmail,
                          ),
                        );

                        expect(
                          ActionSnackBarHelper.lastMessage,
                          'Invalid email format',
                        );
                      },
                    );
                  });
                }
              case Unauthorized(:final reason):
                {
                  group('(§update unauthorized', () {
                    testWidgets('should show greyed out action icon', (
                      WidgetTester tester,
                    ) async {
                      await tester.renderUpdateUserEmailIcon(
                        currentUser: currentUser,
                        targetUser: targetUser,
                      );

                      final updateEmailIcon = find.byType(UpdateUserEmailIcon);
                      expect(updateEmailIcon, findsOne);

                      final actionIcon = updateEmailIcon.findDescendant(
                        ActionIcon,
                      );
                      expect(actionIcon, findsOne);
                      final actionIconWidget = tester.widget<ActionIcon>(
                        actionIcon,
                      );

                      expect(actionIconWidget.isGreyedOut, isTrue);
                    });

                    testWidgets('shows snackbar when action icon is tapped', (
                      WidgetTester tester,
                    ) async {
                      await tester.renderUpdateUserEmailIcon(
                        currentUser: currentUser,
                        targetUser: targetUser,
                      );

                      final updateEmailIcon = find.byType(UpdateUserEmailIcon);
                      final actionIcon = updateEmailIcon.findDescendant(
                        ActionIcon,
                      );
                      expect(actionIcon, findsOne);

                      await tester.tap(actionIcon);
                      await tester.pumpAndSettle();
                      final updateEmailDialogChild = find.byType(
                        UpdateUserEmailDialogChild,
                      );

                      expect(updateEmailDialogChild, findsNothing);
                      switch (reason as UpdateUserEmailUnauthorizedReason) {
                        case CannotUpdateEmailOnAnalyst():
                          expect(
                            ActionSnackBarHelper.lastMessage,
                            'You cannot update the email of an analyst.',
                          );
                        case CanOnlyUpdateEmailOnSelf():
                          expect(
                            ActionSnackBarHelper.lastMessage,
                            'You can only update your own email.',
                          );
                      }
                    });
                  });
                }
            }
          },
        );
      }
    }
  });
}
