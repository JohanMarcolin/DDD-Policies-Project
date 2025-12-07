import 'package:client/presentation/views/login_view/login_view.dart';
import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:client/presentation/widgets/confirm_input_dialog.dart';
import 'package:domain/policies/action_authorization_policies/user_administration/user_administration_policy.dart';
import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:domain/value_objects/role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/domain/user_administration_service.dart';
import 'package:test_utils/user_test_fixture.dart';
import 'package:integration_test/integration_test.dart';
import '../integration_test_server_fixture.dart';
import '../utils/extensions/widget_tester_extensions.dart';

/// Entry point for Update user password integration tests.
///
/// Covers all scenarios for updating password on self and other users based on the [ViewUserPolicy] and [UpdateUserPasswordPolicy].
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Update user password Scenario', () {
    setUp(() async => await IntegrationTestServerFixture.setup());
    tearDown(() async => await IntegrationTestServerFixture.teardown());

    final UserAdministrationService userAdministrationService = createStubbedUserAdministrationService();

    for (final initiatorRole in Role.values) {
      final initiatorRoleName = initiatorRole.name;

      testWidgets('$initiatorRoleName updating password on self scenario', (WidgetTester tester) async {
        final self = await IntegrationTestServerFixture.createUserFixture(role: initiatorRole);

        final canViewSelf = await userAdministrationService.authorizeViewUser(
          initiator: self.user,
          target: self.user,
          onAuthorized: () async {
            await tester.assertUserTileIsVisible(initiator: self, target: self);
            return true;
          },
          onUnauthorized: (_) async {
            await tester.assertUserTileIsNotVisible(initiator: self, target: self);
            return false;
          },
        );

        if (!canViewSelf) return;

        await userAdministrationService.authorizeUpdateUserPassword(
          initiator: self.user,
          target: self.user,
          onAuthorized: () async => await _assertUpdatePasswordSucceeds(tester: tester, initiator: self, target: self),
          onUnauthorized: (_) async =>
              await _assertUpdatePasswordIsBlocked(tester: tester, initiator: self, target: self),
        );
      });
      for (final targetRole in Role.values) {
        testWidgets('$initiatorRoleName updating password on ${targetRole.name} scenario', (WidgetTester tester) async {
          final initiator = await IntegrationTestServerFixture.createUserFixture(role: initiatorRole);
          final target = await IntegrationTestServerFixture.createUserFixture(role: targetRole);

          final canViewTarget = await userAdministrationService.authorizeViewUser(
            initiator: initiator.user,
            target: target.user,
            onAuthorized: () async {
              await tester.assertUserTileIsVisible(initiator: initiator, target: target);
              return true;
            },
            onUnauthorized: (_) async {
              await tester.assertUserTileIsNotVisible(initiator: initiator, target: target);
              return false;
            },
          );

          if (!canViewTarget) return;

          await userAdministrationService.authorizeUpdateUserPassword(
            initiator: initiator.user,
            target: target.user,
            onAuthorized: () async =>
                await _assertUpdatePasswordSucceeds(tester: tester, initiator: initiator, target: target),
            onUnauthorized: (_) async =>
                await _assertUpdatePasswordIsBlocked(tester: tester, initiator: initiator, target: target),
          );
        });
      }
    }
  });
}

Future<void> _assertUpdatePasswordSucceeds({
  required WidgetTester tester,
  required UserTestFixture initiator,
  required UserTestFixture target,
}) async {
  var targetUserRole = target.user.role.name;

  await tester.startApp();

  await tester.login(email: initiator.user.email, password: initiator.password);

  final targetUserTile = tester.findUserTileByUserId(target.user.userId);
  expect(targetUserTile, findsOne, reason: 'UserTile should be found for $targetUserRole target');

  final updatePasswordIcon = find.descendant(of: targetUserTile, matching: find.byType(UpdateUserPasswordIcon));

  await tester.tap(updatePasswordIcon);
  await tester.pumpAndSettle();

  final passwordUpdateDialogChild = find.byType(UpdateUserPasswordDialogChild);
  expect(passwordUpdateDialogChild, findsOne, reason: 'Password update dialog should be shown');

  final confirmInputDialog = find.descendant(of: passwordUpdateDialogChild, matching: find.byType(ConfirmInputDialog));

  expect(confirmInputDialog, findsOne, reason: 'Confirm input dialog should be shown');

  final passwordField = find.descendant(of: confirmInputDialog, matching: find.byType(TextField));

  final newPassword = PasswordValidationPolicy.generatePassword();

  await tester.enterText(passwordField, newPassword.value);

  final confirmButton = tester.findConfirmButton();

  await tester.tap(confirmButton);
  await tester.pumpAndSettle();

  expect(confirmInputDialog, findsNothing, reason: 'Dialog should close after password update');

  await tester.logout();

  expect(find.byType(LoginView), findsOne, reason: 'Should show LoginView after logout');

  await tester.login(email: target.user.email, password: target.password);

  expect(
    find.byType(UserAdministrationView),
    findsNothing,
    reason: 'Login should fail with old password for $targetUserRole target',
  );

  await tester.login(email: target.user.email, password: newPassword);

  expect(find.byType(UserAdministrationView), findsOne, reason: 'Login should succeed with new password');
}

Future<void> _assertUpdatePasswordIsBlocked({
  required WidgetTester tester,
  required UserTestFixture initiator,
  required UserTestFixture target,
}) async {
  await tester.startApp();

  await tester.login(email: initiator.email, password: initiator.password);

  final targetUserTile = tester.findUserTileByUserId(target.user.userId);
  expect(targetUserTile, findsOne, reason: 'UserTile should be found for ${target.user.role.name} target');

  final updatePasswordIcon = find.descendant(of: targetUserTile, matching: find.byType(UpdateUserPasswordIcon));

  await tester.tap(updatePasswordIcon);
  await tester.pumpAndSettle();

  final passwordUpdateDialogChild = find.byType(UpdateUserPasswordDialogChild);
  expect(passwordUpdateDialogChild, findsNothing, reason: 'Password update dialog should not be shown');

  await tester.logout();
}
