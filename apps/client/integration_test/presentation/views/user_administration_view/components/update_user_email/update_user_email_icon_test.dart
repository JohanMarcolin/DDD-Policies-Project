import 'package:api_error_codes/api_error_codes.dart';
import 'package:client/infrastructure/apis/user_api.dart';
import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:client/presentation/widgets/action_icon.dart';
import 'package:client/presentation/widgets/action_snack_bar_helper.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/mocks/mock_user_credentials.dart';
import 'package:test_utils/mocks/mock_user_repository.dart';
import 'package:test_utils/mocks/mock_users.dart';
import 'package:test_utils/user_test_runner.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../utils/extensions/widget_finder_extensions.dart';
import '../../../../../utils/extensions/widget_tester_extensions.dart';

late MockUserRepository mockUserRepository;

extension on WidgetTester {
  Future<void> renderUpdateUserEmailIcon({required User currentUser, required User targetUser}) async {
    return renderWidgetWithBlocStubs(
      testWidget: UpdateUserEmailIcon(user: targetUser),
      mockCurrentUser: currentUser,
      mockUserRepository: mockUserRepository,
    );
  }
}

/// Entry point for [UpdateUserEmailIcon] integration tests.
///
/// Covers presentation scenarios for successful and failed update user email attempts.
Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    mockUserRepository = MockUserRepository();
  });

  UserTestRunner.forEachUserPairWithPolicy(
    policy: UpdateUserEmailPolicy(),
    users: allMockUserPairs,
    onAuthorized: (currentUser, targetUser) {
      testWidgets('shows solid action icon', (WidgetTester tester) async {
        await tester.renderUpdateUserEmailIcon(currentUser: currentUser, targetUser: targetUser);

        final updateEmailIcon = find.byType(UpdateUserEmailIcon);
        expect(updateEmailIcon, findsOne);

        final actionIcon = updateEmailIcon.findDescendant(ActionIcon);
        expect(actionIcon, findsOne);
        final actionIconWidget = tester.widget<ActionIcon>(actionIcon);

        expect(actionIconWidget.isGreyedOut, isFalse);
      });

      testWidgets('shows dialog when action icon is tapped', (WidgetTester tester) async {
        await tester.renderUpdateUserEmailIcon(currentUser: currentUser, targetUser: targetUser);

        final updateEmailIcon = find.byType(UpdateUserEmailIcon);
        final actionIcon = updateEmailIcon.findDescendant(ActionIcon);
        expect(actionIcon, findsOne);

        await tester.tap(actionIcon);
        await tester.pumpAndSettle();

        final updateEmailDialogChild = find.byType(UpdateUserEmailDialogChild);
        expect(updateEmailDialogChild, findsOne);

        final isUserUpdatingSelf = currentUser.isSameAs(targetUser);

        final expectedTitle = isUserUpdatingSelf ? 'Update your email' : 'Update user email';
        expect(find.text(expectedTitle), findsOne);

        final expectedLabel = 'New email';
        expect(find.text(expectedLabel), findsOne);
      });

      testWidgets('cancel closes dialog', (WidgetTester tester) async {
        await tester.renderUpdateUserEmailIcon(currentUser: currentUser, targetUser: targetUser);
        final actionIcon = find.byType(ActionIcon);
        await tester.tap(actionIcon);
        await tester.pumpAndSettle();
        expect(find.byType(UpdateUserEmailDialogChild), findsOne);
        final cancelButton = find.text('Cancel');
        await tester.tap(cancelButton);
        await tester.pumpAndSettle();
        expect(find.byType(UpdateUserEmailDialogChild), findsNothing);
      });

      testWidgets('confirm with valid email shows success snackbar and closes dialog', (WidgetTester tester) async {
        when(
          () => mockUserRepository.updateEmail(userId: targetUser.userId, newEmail: mockValidEmail),
        ).thenAnswer((_) async => {});

        await tester.renderUpdateUserEmailIcon(currentUser: currentUser, targetUser: targetUser);
        final actionIcon = find.byType(ActionIcon);
        await tester.tap(actionIcon);
        await tester.pumpAndSettle();
        expect(find.byType(UpdateUserEmailDialogChild), findsOne);
        final emailField = find.byType(TextField);
        await tester.enterText(emailField, mockValidEmail.value);

        final confirmButton = find.text('Confirm');
        await tester.tap(confirmButton);
        await tester.pumpAndSettle();

        expect(find.byType(UpdateUserEmailDialogChild), findsNothing);

        verify(() => mockUserRepository.updateEmail(userId: targetUser.userId, newEmail: mockValidEmail)).called(1);
        expect(ActionSnackBarHelper.lastMessage, 'Email updated successfully');
      });

      for (final invalidEmail in mockInvalidEmails) {
        testWidgets('confirm with invalid email "${invalidEmail.value}" shows error snackbar and keeps dialog open', (
          WidgetTester tester,
        ) async {
          await tester.renderUpdateUserEmailIcon(currentUser: currentUser, targetUser: targetUser);

          final actionIcon = find.byType(ActionIcon);
          await tester.tap(actionIcon);
          await tester.pumpAndSettle();
          expect(find.byType(UpdateUserEmailDialogChild), findsOne);
          final emailField = find.byType(TextField);
          await tester.enterText(emailField, invalidEmail.value);
          final confirmButton = find.text('Confirm');
          await tester.tap(confirmButton);
          await tester.pumpAndSettle();
          expect(find.byType(UpdateUserEmailDialogChild), findsOne);

          verifyNever(() => mockUserRepository.updateEmail(userId: targetUser.userId, newEmail: invalidEmail));

          expect(ActionSnackBarHelper.lastMessage, 'Invalid email format');
        });
      }
      testWidgets('confirm with already taken email shows error snackbar and keeps dialog open', (
        WidgetTester tester,
      ) async {
        final isUpdatingSelf = currentUser.isSameAs(targetUser);
        final takenEmail = isUpdatingSelf ? currentUser.email : targetUser.email;

        when(() => mockUserRepository.updateEmail(userId: targetUser.userId, newEmail: takenEmail)).thenThrow(
          UserApiException(
            isUpdatingSelf ? UpdateUserEmailTakenBySelf().toString() : UpdateUserEmailTakenByOther().toString(),
          ),
        );

        await tester.renderUpdateUserEmailIcon(currentUser: currentUser, targetUser: targetUser);

        final actionIcon = find.byType(ActionIcon);
        await tester.tap(actionIcon);
        await tester.pumpAndSettle();
        expect(find.byType(UpdateUserEmailDialogChild), findsOne);
        final emailField = find.byType(TextField);
        await tester.enterText(emailField, takenEmail.value);
        final confirmButton = find.text('Confirm');
        await tester.tap(confirmButton);
        await tester.pumpAndSettle();
        expect(find.byType(UpdateUserEmailDialogChild), findsOne);

        verify(() => mockUserRepository.updateEmail(userId: targetUser.userId, newEmail: takenEmail)).called(1);

        if (isUpdatingSelf) {
          expect(ActionSnackBarHelper.lastMessage, 'This is your current email');
        } else {
          expect(ActionSnackBarHelper.lastMessage, 'This email is already taken');
        }
      });
    },
    onUnauthorized: (currentUser, targetUser, reason) {
      testWidgets('should show greyed out action icon', (WidgetTester tester) async {
        await tester.renderUpdateUserEmailIcon(currentUser: currentUser, targetUser: targetUser);

        final updateEmailIcon = find.byType(UpdateUserEmailIcon);
        expect(updateEmailIcon, findsOne);

        final actionIcon = updateEmailIcon.findDescendant(ActionIcon);
        expect(actionIcon, findsOne);
        final actionIconWidget = tester.widget<ActionIcon>(actionIcon);

        expect(actionIconWidget.isGreyedOut, isTrue);
      });

      testWidgets('shows snackbar when action icon is tapped', (WidgetTester tester) async {
        await tester.renderUpdateUserEmailIcon(currentUser: currentUser, targetUser: targetUser);

        final updateEmailIcon = find.byType(UpdateUserEmailIcon);
        final actionIcon = updateEmailIcon.findDescendant(ActionIcon);
        expect(actionIcon, findsOne);

        await tester.tap(actionIcon);
        await tester.pumpAndSettle();
        final updateEmailDialogChild = find.byType(UpdateUserEmailDialogChild);

        expect(updateEmailDialogChild, findsNothing);
        switch (reason as UpdateUserEmailUnauthorizedReason) {
          case CannotUpdateEmailOnAnalyst():
            expect(ActionSnackBarHelper.lastMessage, 'You cannot update the email of an analyst');
          case CanOnlyUpdateEmailOnSelf():
            expect(ActionSnackBarHelper.lastMessage, 'You can only update your own email');
        }
      });
    },
  );
}
