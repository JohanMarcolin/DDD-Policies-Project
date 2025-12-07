import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:client/presentation/widgets/action_icon.dart';
import 'package:client/presentation/widgets/action_snack_bar_helper.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_authorization_policies/user_administration/user_administration_policy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/domain/user_administration_service.dart';
import 'package:test_utils/mocks/mock_user_credentials.dart';
import 'package:test_utils/mocks/mock_user_repository.dart';
import 'package:test_utils/mocks/mock_users.dart';
import 'package:test_utils/user_pair_test_util.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../utils/extensions/widget_finder_extensions.dart';
import '../../../../../utils/extensions/widget_tester_extensions.dart';

late MockUserRepository mockUserRepository;

extension on WidgetTester {
  Future<void> renderUpdateUserPasswordIcon({required User initiator, required User target}) async {
    return renderWidgetWithBlocStubs(
      testWidget: UpdateUserPasswordIcon(user: target),
      mockCurrentUser: initiator,
      mockUserRepository: mockUserRepository,
    );
  }
}

/// Entry point for [UpdateUserPasswordIcon] integration tests.
///
/// Covers presentation scenarios for successful and failed update user password attempts.
Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final userAdministrationService = createStubbedUserAdministrationService();

  setUp(() {
    mockUserRepository = MockUserRepository();
  });

  UserPairTestUtil.forEachUserPair(
    users: allMockUserPairs,
    onUserPair: (initiator, target) {
      userAdministrationService.authorizeUpdateUserPassword(
        initiator: initiator,
        target: target,
        onAuthorized: () {
          testWidgets('shows solid action icon', (WidgetTester tester) async {
            await tester.renderUpdateUserPasswordIcon(initiator: initiator, target: target);

            final updatePasswordIcon = find.byType(UpdateUserPasswordIcon);
            expect(updatePasswordIcon, findsOne);

            final actionIcon = updatePasswordIcon.findDescendant(ActionIcon);
            expect(actionIcon, findsOne);
            final actionIconWidget = tester.widget<ActionIcon>(actionIcon);

            expect(actionIconWidget.isGreyedOut, isFalse);
          });

          testWidgets('shows dialog when action icon is tapped', (WidgetTester tester) async {
            await tester.renderUpdateUserPasswordIcon(initiator: initiator, target: target);

            final updatePasswordIcon = find.byType(UpdateUserPasswordIcon);
            final actionIcon = updatePasswordIcon.findDescendant(ActionIcon);
            expect(actionIcon, findsOne);

            await tester.tap(actionIcon);
            await tester.pumpAndSettle();

            final updatePasswordDialogChild = find.byType(UpdateUserPasswordDialogChild);
            expect(updatePasswordDialogChild, findsOne);

            final isUserUpdatingSelf = initiator.isSameAs(target);

            final expectedTitle = isUserUpdatingSelf ? 'Update your password' : 'Update user password';
            expect(find.text(expectedTitle), findsOne);

            final expectedLabel = 'New password';
            expect(find.text(expectedLabel), findsOne);
          });

          testWidgets('cancel closes dialog', (WidgetTester tester) async {
            await tester.renderUpdateUserPasswordIcon(initiator: initiator, target: target);
            final actionIcon = find.byType(ActionIcon);
            await tester.tap(actionIcon);
            await tester.pumpAndSettle();
            expect(find.byType(UpdateUserPasswordDialogChild), findsOne);
            final cancelButton = find.text('Cancel');
            await tester.tap(cancelButton);
            await tester.pumpAndSettle();
            expect(find.byType(UpdateUserPasswordDialogChild), findsNothing);
          });

          testWidgets('confirm with valid password shows success snackbar and closes dialog', (
            WidgetTester tester,
          ) async {
            when(
              () => mockUserRepository.updatePassword(userId: target.userId, newPassword: mockValidPassword),
            ).thenAnswer((_) async => {});

            await tester.renderUpdateUserPasswordIcon(initiator: initiator, target: target);
            final actionIcon = find.byType(ActionIcon);
            await tester.tap(actionIcon);
            await tester.pumpAndSettle();
            expect(find.byType(UpdateUserPasswordDialogChild), findsOne);
            final passwordField = find.byType(TextField);
            await tester.enterText(passwordField, mockValidPassword.value);

            final confirmButton = find.text('Confirm');
            await tester.tap(confirmButton);
            await tester.pumpAndSettle();

            expect(find.byType(UpdateUserPasswordDialogChild), findsNothing);

            verify(
              () => mockUserRepository.updatePassword(userId: target.userId, newPassword: mockValidPassword),
            ).called(1);
            expect(ActionSnackBarHelper.lastMessage, 'Password updated successfully');
          });

          for (final invalidPassword in mockInvalidPasswords) {
            testWidgets(
              'confirm with invalid password "${invalidPassword.value}" shows error snackbar and keeps dialog open',
              (WidgetTester tester) async {
                await tester.renderUpdateUserPasswordIcon(initiator: initiator, target: target);

                final actionIcon = find.byType(ActionIcon);
                await tester.tap(actionIcon);
                await tester.pumpAndSettle();
                expect(find.byType(UpdateUserPasswordDialogChild), findsOne);
                final passwordField = find.byType(TextField);
                await tester.enterText(passwordField, invalidPassword.value);
                final confirmButton = find.text('Confirm');
                await tester.tap(confirmButton);
                await tester.pumpAndSettle();
                expect(find.byType(UpdateUserPasswordDialogChild), findsOne);

                verifyNever(
                  () => mockUserRepository.updatePassword(userId: target.userId, newPassword: invalidPassword),
                );

                String expectedMessage;
                if (invalidPassword == mockTooShortPassword) {
                  expectedMessage = 'Password is too short';
                } else if (invalidPassword == mockTooLongPassword) {
                  expectedMessage = 'Password is too long';
                } else if (invalidPassword == mockMissingUppercasePassword) {
                  expectedMessage = 'Password must contain at least one uppercase letter';
                } else if (invalidPassword == mockMissingLowercasePassword) {
                  expectedMessage = 'Password must contain at least one lowercase letter';
                } else if (invalidPassword == mockMissingNumberPassword) {
                  expectedMessage = 'Password must contain at least one number';
                } else if (invalidPassword == mockMissingSpecialCharPassword) {
                  expectedMessage = 'Password must contain at least one special character';
                } else {
                  expectedMessage = 'Invalid password';
                }
                expect(ActionSnackBarHelper.lastMessage, expectedMessage);
              },
            );
          }
        },
        onUnauthorized: (reason) {
          testWidgets('should show greyed out action icon', (WidgetTester tester) async {
            await tester.renderUpdateUserPasswordIcon(initiator: initiator, target: target);

            final updatePasswordIcon = find.byType(UpdateUserPasswordIcon);
            expect(updatePasswordIcon, findsOne);

            final actionIcon = updatePasswordIcon.findDescendant(ActionIcon);
            expect(actionIcon, findsOne);
            final actionIconWidget = tester.widget<ActionIcon>(actionIcon);

            expect(actionIconWidget.isGreyedOut, isTrue);
          });

          testWidgets('shows snackbar when action icon is tapped', (WidgetTester tester) async {
            await tester.renderUpdateUserPasswordIcon(initiator: initiator, target: target);

            final updatePasswordIcon = find.byType(UpdateUserPasswordIcon);
            final actionIcon = updatePasswordIcon.findDescendant(ActionIcon);
            expect(actionIcon, findsOne);

            await tester.tap(actionIcon);
            await tester.pumpAndSettle();
            final updatePasswordDialogChild = find.byType(UpdateUserPasswordDialogChild);

            expect(updatePasswordDialogChild, findsNothing);
            switch (reason) {
              case CannotUpdatePasswordOnAnalyst():
                expect(ActionSnackBarHelper.lastMessage, 'You cannot update the password of an analyst');
              case CanOnlyUpdatePasswordOnSelf():
                expect(ActionSnackBarHelper.lastMessage, 'You can only update your own password');
            }
          });
        },
      );
    },
  );
}
