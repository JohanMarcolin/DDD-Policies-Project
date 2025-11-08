import 'package:client/infrastructure/apis/http_api.dart';
import 'package:client/infrastructure/apis/test_api.dart';
import 'package:client/infrastructure/services/auth_token_service.dart';
import 'package:client/presentation/views/login_view/login_view.dart';
import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:client/presentation/widgets/confirm_dialog.dart';
import 'package:client/presentation/widgets/confirm_input_dialog.dart';
import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:client/main.dart' as app;
import 'package:server/test/utils/factories/test_server_factory.dart';

late TestApi testApi;
late AuthTokenService authTokenService;
late List<TestUserEntry> testUserEntries;
late TestUserEntry testUserEntry;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('User Lifecycle', () {
    setUpAll(() async {
      await TestServerFactory.start(enableTestRoutes: true);
      HttpApi.baseUrl = TestServerFactory.baseUrl;
      testApi = TestApi();
      authTokenService = AuthTokenService();
    });

    setUp(() async {
      testUserEntries = await testApi.createAllUserPairs();
      testUserEntry = testUserEntries.first;
    });

    tearDown(() async {
      await testApi.deleteAllTestUsers();
      await authTokenService.clearTokens();
    });

    tearDownAll(() async {
      await TestServerFactory.stop();
      await authTokenService.clearTokens();
    });

    testWidgets('should login successfully', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.byType(LoginView), findsOne);

      await tester.enterText(
        find.byType(LoginEmailField),
        testUserEntry.email.value,
      );
      await tester.enterText(
        find.byType(LoginPasswordField),
        testUserEntry.password.value,
      );
      await tester.tap(find.byType(LoginButton));
      await tester.pumpAndSettle();

      expect(find.byType(UserAdministrationView), findsOne);
      expect(find.byType(UserList), findsOne);
    });

    testWidgets('should persist session on app restart', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Login first
      await tester.enterText(
        find.byType(LoginEmailField),
        testUserEntry.email.value,
      );
      await tester.enterText(
        find.byType(LoginPasswordField),
        testUserEntry.password.value,
      );
      await tester.tap(find.byType(LoginButton));
      await tester.pumpAndSettle();

      // Simulate app restart
      app.main();
      await tester.pumpAndSettle();

      // Should show UserAdministrationView due to refresh token/session
      expect(find.byType(UserAdministrationView), findsOne);
    });

    testWidgets('should update email successfully', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Login first
      await tester.enterText(
        find.byType(LoginEmailField),
        testUserEntry.email.value,
      );
      await tester.enterText(
        find.byType(LoginPasswordField),
        testUserEntry.password.value,
      );
      await tester.tap(find.byType(LoginButton));
      await tester.pumpAndSettle();

      final userTile = find.byWidgetPredicate(
        (widget) =>
            widget is UserTile &&
            widget.user.email.value == testUserEntry.email.value,
      );
      expect(userTile, findsOne);

      final updateEmailIcon = find.descendant(
        of: userTile,
        matching: find.byType(UpdateUserEmailIcon),
      );

      await tester.tap(updateEmailIcon);
      await tester.pumpAndSettle();

      final emailUpdateDialogChild = find.byType(UpdateUserEmailDialogChild);
      expect(emailUpdateDialogChild, findsOne);

      final confirmInputDialog = find.descendant(
        of: emailUpdateDialogChild,
        matching: find.byType(ConfirmInputDialog),
      );

      expect(confirmInputDialog, findsOne);

      final emailField = find.descendant(
        of: confirmInputDialog,
        matching: find.byType(TextField),
      );

      await tester.enterText(emailField, 'new_email@example.com');

      final confirmButton = find.byWidgetPredicate(
        (widget) =>
            widget is TextButton &&
            widget.child is Text &&
            (widget.child as Text).data == 'Confirm',
      );

      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      expect(userTile, findsNothing);

      final updatedUserTile = find.byWidgetPredicate(
        (widget) =>
            widget is UserTile &&
            widget.user.email.value == 'new_email@example.com',
      );
      expect(updatedUserTile, findsOne);
    });

    testWidgets('should update password successfully', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Login first
      await tester.enterText(
        find.byType(LoginEmailField),
        testUserEntry.email.value,
      );
      await tester.enterText(
        find.byType(LoginPasswordField),
        testUserEntry.password.value,
      );
      await tester.tap(find.byType(LoginButton));
      await tester.pumpAndSettle();

      final userTile = find.byWidgetPredicate(
        (widget) =>
            widget is UserTile &&
            widget.user.email.value == testUserEntry.email.value,
      );
      expect(userTile, findsOne);

      final updatePasswordIcon = find.descendant(
        of: userTile,
        matching: find.byType(UpdateUserPasswordIcon),
      );

      await tester.tap(updatePasswordIcon);
      await tester.pumpAndSettle();

      final passwordUpdateDialogChild = find.byType(
        UpdateUserPasswordDialogChild,
      );
      expect(passwordUpdateDialogChild, findsOne);

      final confirmInputDialog = find.descendant(
        of: passwordUpdateDialogChild,
        matching: find.byType(ConfirmInputDialog),
      );

      expect(confirmInputDialog, findsOne);

      final passwordField = find.descendant(
        of: confirmInputDialog,
        matching: find.byType(TextField),
      );

      final newPassword = PasswordValidationPolicy.generatePassword().value;

      await tester.enterText(passwordField, newPassword);

      final confirmButton = find.byWidgetPredicate(
        (widget) =>
            widget is TextButton &&
            widget.child is Text &&
            (widget.child as Text).data == 'Confirm',
      );

      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      expect(
        confirmInputDialog,
        findsNothing,
        reason: 'Dialog should close after password update',
      );

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      expect(find.byType(LoginView), findsOne);

      // Login should fail with old password
      await tester.enterText(
        find.byType(LoginEmailField),
        testUserEntry.email.value,
      );
      await tester.enterText(
        find.byType(LoginPasswordField),
        testUserEntry.password.value,
      );
      await tester.tap(find.byType(LoginButton));
      await tester.pumpAndSettle();

      expect(find.byType(UserAdministrationView), findsNothing);

      // Login should succeed with new password
      await tester.enterText(
        find.byType(LoginEmailField),
        testUserEntry.email.value,
      );
      await tester.enterText(find.byType(LoginPasswordField), newPassword);
      await tester.tap(find.byType(LoginButton));
      await tester.pumpAndSettle();

      expect(find.byType(UserAdministrationView), findsOne);
    });

    testWidgets('should logout successfully', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login first
      await tester.enterText(
        find.byType(LoginEmailField),
        testUserEntry.email.value,
      );
      await tester.enterText(
        find.byType(LoginPasswordField),
        testUserEntry.password.value,
      );
      await tester.tap(find.byType(LoginButton));
      await tester.pumpAndSettle();

      expect(find.byType(UserAdministrationView), findsOne);

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      expect(find.byType(LoginView), findsOne);
    });

    testWidgets('should delete user successfully', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login first
      await tester.enterText(
        find.byType(LoginEmailField),
        testUserEntry.email.value,
      );
      await tester.enterText(
        find.byType(LoginPasswordField),
        testUserEntry.password.value,
      );
      await tester.tap(find.byType(LoginButton));
      await tester.pumpAndSettle();

      expect(find.byType(UserAdministrationView), findsOne);

      final userTile = find.byWidgetPredicate(
        (widget) =>
            widget is UserTile &&
            widget.user.email.value == testUserEntry.email.value,
      );
      expect(userTile, findsOne);

      final deleteUserIcon = find.descendant(
        of: userTile,
        matching: find.byType(DeleteUserIcon),
      );

      await tester.tap(deleteUserIcon);
      await tester.pumpAndSettle();

      final deleteUserDialogChild = find.byType(DeleteUserDialogChild);
      expect(deleteUserDialogChild, findsOne);

      final confirmDialog = find.descendant(
        of: deleteUserDialogChild,
        matching: find.byType(ConfirmDialog),
      );

      expect(confirmDialog, findsOne);

      final confirmButton = find.byWidgetPredicate(
        (widget) =>
            widget is TextButton &&
            widget.child is Text &&
            (widget.child as Text).data == 'Confirm',
      );

      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      expect(find.byType(LoginView), findsOne);

      // Attempt to login again should fail since user is deleted
      await tester.enterText(
        find.byType(LoginEmailField),
        testUserEntry.email.value,
      );
      await tester.enterText(
        find.byType(LoginPasswordField),
        testUserEntry.password.value,
      );
      await tester.tap(find.byType(LoginButton));
      await tester.pumpAndSettle();

      expect(find.byType(UserAdministrationView), findsNothing);
    });
  });
}
