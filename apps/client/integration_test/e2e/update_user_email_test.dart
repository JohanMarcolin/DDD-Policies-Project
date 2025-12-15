import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:client/presentation/widgets/confirm_input_dialog.dart';
import 'package:domain/policies/action_authorization_policies/user_administration/user_administration_policy.dart';
import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/domain/user_administration_service.dart';
import 'package:test_utils/fixtures/user/user_test_fixture.dart';
import 'package:integration_test/integration_test.dart';
import '../utils/extensions/widget_tester_extensions.dart';
import '../utils/integration_test_server_fixture.dart';

/// Entry point for Update user email integration tests.
///
/// Covers all scenarios for updating email on self and other users based on the [ViewUserPolicy] and [UpdateUserEmailPolicy].
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Update user email Scenario', () {
    setUp(() async => await IntegrationTestServerFixture.setup());
    tearDown(() async => await IntegrationTestServerFixture.teardown());

    final UserAdministrationService userAdministrationService = createStubbedUserAdministrationService();

    for (final initiatorRole in Role.values) {
      testWidgets('${initiatorRole.name} updating email on self scenario', (WidgetTester tester) async {
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

        await userAdministrationService.authorizeUpdateUserEmail(
          initiator: self.user,
          target: self.user,
          onAuthorized: () async => await _assertUpdateEmailSucceeds(tester: tester, initiator: self, target: self),
          onUnauthorized: (_) async => await _assertUpdateEmailIsBlocked(tester: tester, initiator: self, target: self),
        );
      });
      for (final targetRole in Role.values) {
        testWidgets('${initiatorRole.name} updating email on ${targetRole.name} scenario', (WidgetTester tester) async {
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

          await userAdministrationService.authorizeUpdateUserEmail(
            initiator: initiator.user,
            target: target.user,
            onAuthorized: () async =>
                await _assertUpdateEmailSucceeds(tester: tester, initiator: initiator, target: target),
            onUnauthorized: (_) async =>
                await _assertUpdateEmailIsBlocked(tester: tester, initiator: initiator, target: target),
          );
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

Future<void> _assertUpdateEmailIsBlocked({
  required WidgetTester tester,
  required UserTestFixture initiator,
  required UserTestFixture target,
}) async {
  await tester.startApp();

  await tester.login(email: initiator.email, password: initiator.password);

  final targetUserTile = tester.findUserTileByUserId(target.user.userId);
  expect(targetUserTile, findsOne, reason: 'UserTile should be found for ${target.user.role.name} target');

  final updateEmailIcon = find.descendant(of: targetUserTile, matching: find.byType(UpdateUserEmailIcon));

  await tester.tap(updateEmailIcon);
  await tester.pumpAndSettle();

  final emailUpdateDialogChild = find.byType(UpdateUserEmailDialogChild);
  expect(emailUpdateDialogChild, findsNothing, reason: 'Email update dialog should not be shown');

  await tester.logout();
}
