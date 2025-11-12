import 'package:client/infrastructure/apis/http_api.dart';
import 'package:client/infrastructure/apis/test_api.dart';
import 'package:client/infrastructure/services/auth_token_service.dart';
import 'package:client/presentation/views/login_view/login_view.dart';
import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:client/presentation/widgets/confirm_input_dialog.dart';
import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../utils/extensions/widget_tester_extension.dart';
import '../utils/test_server_fixture.dart';

late TestApi testApi;
late AuthTokenService authTokenService;
late List<UserTestFixture> testUserTestFixtures;
late UserTestFixture userTestFixture;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Update User Password', () {
    setUp(() async => await TestServerFixture.setup());
    tearDown(() async => await TestServerFixture.teardown());

    testWidgets('should update password successfully', (
      WidgetTester tester,
    ) async {
      await tester.startApp();

      await tester.login(
        email: userTestFixture.user.email,
        password: userTestFixture.password,
      );

      final userTile = tester.findUserTileByEmail(userTestFixture.user.email);
      expect(
        userTile,
        findsOne,
        reason: 'UserTile should be found for logged in user',
      );

      final updatePasswordIcon = find.descendant(
        of: userTile,
        matching: find.byType(UpdateUserPasswordIcon),
      );

      await tester.tap(updatePasswordIcon);
      await tester.pumpAndSettle();

      final passwordUpdateDialogChild = find.byType(
        UpdateUserPasswordDialogChild,
      );
      expect(
        passwordUpdateDialogChild,
        findsOne,
        reason: 'Password update dialog should be shown',
      );

      final confirmInputDialog = find.descendant(
        of: passwordUpdateDialogChild,
        matching: find.byType(ConfirmInputDialog),
      );

      expect(
        confirmInputDialog,
        findsOne,
        reason: 'Confirm input dialog should be shown',
      );

      final passwordField = find.descendant(
        of: confirmInputDialog,
        matching: find.byType(TextField),
      );

      final newPassword = PasswordValidationPolicy.generatePassword();

      await tester.enterText(passwordField, newPassword.value);

      final confirmButton = tester.findConfirmButton();

      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      expect(
        confirmInputDialog,
        findsNothing,
        reason: 'Dialog should close after password update',
      );

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      expect(
        find.byType(LoginView),
        findsOne,
        reason: 'Should show LoginView after logout',
      );

      await tester.login(
        email: userTestFixture.user.email,
        password: userTestFixture.password,
      );

      expect(
        find.byType(UserAdministrationView),
        findsNothing,
        reason: 'Login should fail with old password',
      );

      await tester.login(
        email: userTestFixture.user.email,
        password: newPassword,
      );

      expect(
        find.byType(UserAdministrationView),
        findsOne,
        reason: 'Login should succeed with new password',
      );
    });
  });
}
