import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:client/presentation/widgets/confirm_input_dialog.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:global_utils/test/user_test_fixture.dart';
import 'package:integration_test/integration_test.dart';

import '../integration_test_server_fixture.dart';
import '../utils/extensions/widget_tester_extensions.dart';

/// Entry point for Update User Email integration tests.
///
/// Covers all scenarios for updating email on self and other users based on the [ViewUserPolicy] and [UpdateUserEmailPolicy].
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Update User Email Scenario', () {
    setUp(() async => await IntegrationTestServerFixture.setup());
    tearDown(() async => await IntegrationTestServerFixture.teardown());

    final viewUserPolicy = ViewUserPolicy();
    final updateUserEmailPolicy = UpdateUserEmailPolicy();

    for (final role in Role.values) {
      testWidgets('${role.name} updating email on self scenario', (WidgetTester tester) async {
        final self = await IntegrationTestServerFixture.createUserFixture(role: role);

        final viewSelf = viewUserPolicy.authorize(self.user, self.user);
        switch (viewSelf) {
          case Authorized():
            await tester.assertUserTileIsVisible(initiator: self, target: self);
          case Unauthorized():
            await tester.assertUserTileIsNotVisible(initiator: self, target: self);
            return;
        }

        final updateEmailOnSelf = updateUserEmailPolicy.authorize(self.user, self.user);
        switch (updateEmailOnSelf) {
          case Authorized():
            await _assertUpdateEmailSucceeds(tester: tester, initiator: self, target: self);
          case Unauthorized():
            await _assertUpdateEmailBlocked(tester: tester, initiator: self, target: self);
        }
      });
      for (final targetRole in Role.values) {
        testWidgets('${role.name} updating email on ${targetRole.name} scenario', (WidgetTester tester) async {
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

          final updateEmailOfTarget = updateUserEmailPolicy.authorize(initiator.user, target.user);
          switch (updateEmailOfTarget) {
            case Authorized():
              await _assertUpdateEmailSucceeds(tester: tester, initiator: initiator, target: target);
            case Unauthorized():
              await _assertUpdateEmailBlocked(tester: tester, initiator: initiator, target: target);
          }
        });
      }
    }
  });
}

Future<void> _assertUpdateEmailSucceeds({
  required WidgetTester tester,
  required UserTestFixture initiator,
  required UserTestFixture target,
}) async {
  var targetUserId = target.user.userId;
  var targetUserRole = target.user.role.name;
  var targetEmail = target.user.email;
  var targetPassword = target.password;

  await tester.startApp();

  await tester.login(email: initiator.email, password: initiator.password);

  final targetUserTile = tester.findUserTileByUserId(targetUserId);
  expect(targetUserTile, findsOne, reason: 'UserTile should be found for $targetUserRole target');

  final targetUserTileWidget = tester.widget<UserTile>(targetUserTile);
  expect(
    targetUserTileWidget.user.email,
    equals(targetEmail),
    reason: 'Target UserTile should show correct email before update',
  );

  final updateEmailIcon = find.descendant(of: targetUserTile, matching: find.byType(UpdateUserEmailIcon));

  await tester.tap(updateEmailIcon);
  await tester.pumpAndSettle();

  final emailUpdateDialogChild = find.byType(UpdateUserEmailDialogChild);
  expect(emailUpdateDialogChild, findsOne, reason: 'Email update dialog should be shown');

  final confirmInputDialog = find.descendant(of: emailUpdateDialogChild, matching: find.byType(ConfirmInputDialog));

  expect(confirmInputDialog, findsOne, reason: 'Confirm input dialog should be shown');

  final emailField = find.descendant(of: confirmInputDialog, matching: find.byType(TextField));

  final newTargetEmail = Email('new_${target.user.userId.value}@example.com');

  await tester.enterText(emailField, newTargetEmail.value);

  final confirmButton = tester.findConfirmButton();

  await tester.tap(confirmButton);
  await tester.pumpAndSettle();

  final updatedTargetUserTile = tester.findUserTileByUserId(targetUserId);
  final updatedTargetUserTileWidget = tester.widget<UserTile>(updatedTargetUserTile);
  expect(
    updatedTargetUserTileWidget.user.email,
    equals(newTargetEmail),
    reason: 'Target UserTile should show correct email after update',
  );

  await tester.logout();

  final oldTargetEmail = targetEmail;

  await tester.login(email: oldTargetEmail, password: targetPassword);

  expect(
    find.byType(UserAdministrationView),
    findsNothing,
    reason: 'Login with old target email should fail after email update for $targetUserRole',
  );

  await tester.login(email: newTargetEmail, password: targetPassword);

  expect(
    find.byType(UserAdministrationView),
    findsOne,
    reason: 'Login with new email should succeed after email update for $targetUserRole',
  );

  await tester.logout();
}

Future<void> _assertUpdateEmailBlocked({
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

  final updateEmailIcon = find.descendant(of: targetUserTile, matching: find.byType(UpdateUserEmailIcon));

  await tester.tap(updateEmailIcon);
  await tester.pumpAndSettle();

  final emailUpdateDialogChild = find.byType(UpdateUserEmailDialogChild);
  expect(emailUpdateDialogChild, findsNothing, reason: 'Email update dialog should not be shown');

  await tester.logout();
}
