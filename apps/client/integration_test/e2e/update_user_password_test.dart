import 'package:client/presentation/views/login_view/login_view.dart';
import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:client/presentation/widgets/confirm_input_dialog.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:domain/value_objects/role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:global_utils/test/user_test_fixture.dart';
import 'package:integration_test/integration_test.dart';

import '../integration_test_server_fixture.dart';
import '../utils/extensions/widget_tester_extensions.dart';

/// Entry point for Update User Password integration tests.
///
/// Covers all scenarios for updating password on self and other users based on the [ViewUserPolicy] and [UpdateUserPasswordPolicy].
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Update User Password Scenario', () {
    setUp(() async => await IntegrationTestServerFixture.setup());
    tearDown(() async => await IntegrationTestServerFixture.teardown());

    final viewUserPolicy = ViewUserPolicy();
    final updateUserPasswordPolicy = UpdateUserPasswordPolicy();

    for (final role in Role.values) {
      testWidgets('${role.name} updating password on self scenario', (WidgetTester tester) async {
        final self = await IntegrationTestServerFixture.createUserFixture(role: role);

        final viewSelf = viewUserPolicy.authorize(self.user, self.user);
        switch (viewSelf) {
          case Authorized():
            await tester.assertUserTileIsVisible(initiator: self, target: self);
          case Unauthorized():
            await tester.assertUserTileIsNotVisible(initiator: self, target: self);
            return;
        }

        final updatePasswordOnSelf = updateUserPasswordPolicy.authorize(self.user, self.user);
        switch (updatePasswordOnSelf) {
          case Authorized():
            await _assertUpdatePasswordSucceeds(tester: tester, initiator: self, target: self);
          case Unauthorized():
            await _assertUpdatePasswordBlocked(tester: tester, initiator: self, target: self);
        }
      });
      for (final targetRole in Role.values) {
        testWidgets('${role.name} updating password on ${targetRole.name} scenario', (WidgetTester tester) async {
          final initiator = await IntegrationTestServerFixture.createUserFixture(role: role);
          final target = await IntegrationTestServerFixture.createUserFixture(role: targetRole);

          final viewTarget = viewUserPolicy.authorize(initiator.user, target.user);
          switch (viewTarget) {
            case Authorized():
              await tester.assertUserTileIsVisible(initiator: initiator, target: target);
            case Unauthorized():
              await tester.assertUserTileIsNotVisible(initiator: initiator, target: target);
              return;
          }

          final updatePasswordOfTarget = updateUserPasswordPolicy.authorize(initiator.user, target.user);
          switch (updatePasswordOfTarget) {
            case Authorized():
              await _assertUpdatePasswordSucceeds(tester: tester, initiator: initiator, target: target);
            case Unauthorized():
              await _assertUpdatePasswordBlocked(tester: tester, initiator: initiator, target: target);
          }
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

Future<void> _assertUpdatePasswordBlocked({
  required WidgetTester tester,
  required UserTestFixture initiator,
  required UserTestFixture target,
}) async {
  var targetUserId = target.user.userId;
  var targetUserRole = target.user.role.name;

  await tester.startApp();

  await tester.login(email: initiator.email, password: initiator.password);

  final targetUserTile = tester.findUserTileByUserId(targetUserId);
  expect(targetUserTile, findsOne, reason: 'UserTile should be found for $targetUserRole target');

  final updatePasswordIcon = find.descendant(of: targetUserTile, matching: find.byType(UpdateUserPasswordIcon));

  await tester.tap(updatePasswordIcon);
  await tester.pumpAndSettle();

  final passwordUpdateDialogChild = find.byType(UpdateUserPasswordDialogChild);
  expect(passwordUpdateDialogChild, findsNothing, reason: 'Password update dialog should not be shown');

  await tester.logout();
}
