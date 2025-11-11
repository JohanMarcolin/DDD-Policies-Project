import 'package:client/infrastructure/apis/http_api.dart';
import 'package:client/infrastructure/apis/test_api.dart';
import 'package:client/infrastructure/services/auth_token_service.dart';
import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:client/presentation/widgets/confirm_input_dialog.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:logger/logger.dart';
import 'package:server/test/utils/factories/test_server_factory.dart';

import '../utils/extensions/widget_tester_extension.dart';

final logger = Logger();

late TestApi testApi;
late AuthTokenService authTokenService;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Update User Email Lifecycle', () {
    setUp(() async {
      await TestServerFactory.start(enableTestRoutes: true);
      HttpApi.baseUrl = TestServerFactory.baseUrl;
      testApi = TestApi();
      authTokenService = AuthTokenService();
    });

    tearDown(() async {
      await testApi.deleteAllTestUsers();
      await authTokenService.clearTokens();
      await TestServerFactory.stop();
    });

    final policy = UpdateUserEmailPolicy();

    for (final initiatorRole in Role.values) {
      testWidgets('initiator: ${initiatorRole.name} can update self', (
        WidgetTester tester,
      ) async {
        final initiatorEntry = await testApi.createUserEntry(
          role: initiatorRole,
        );
        final canUpdateEmailOfSelf = policy.authorize(
          initiatorEntry.user,
          initiatorEntry.user,
        );
        if (canUpdateEmailOfSelf is Authorized) {
          await _testSuccessfulEmailUpdate(
            tester: tester,
            initiatorEntry: initiatorEntry,
            targetEntry: initiatorEntry,
          );
        } else if (canUpdateEmailOfSelf is Unauthorized) {
          logger.i(
            '[AUTH] ${initiatorEntry.role.name} (${initiatorEntry.email.value}) NOT authorized to update self. Reason: ${canUpdateEmailOfSelf.reason.toString()}',
          );
        }
      });
      for (final targetRole in Role.values) {
        testWidgets(
          'initiator: ${initiatorRole.name} can update target: ${targetRole.name}',
          (WidgetTester tester) async {
            final initiatorEntry = await testApi.createUserEntry(
              role: initiatorRole,
            );
            final targetEntry = await testApi.createUserEntry(role: targetRole);
            final canUpdateEmailOfTarget = policy.authorize(
              initiatorEntry.user,
              targetEntry.user,
            );
            if (canUpdateEmailOfTarget is Authorized) {
              await _testSuccessfulEmailUpdate(
                tester: tester,
                initiatorEntry: initiatorEntry,
                targetEntry: targetEntry,
              );
            } else if (canUpdateEmailOfTarget is Unauthorized) {
              logger.i(
                '[AUTH] ${initiatorEntry.role.name} (${initiatorEntry.email.value}) NOT authorized to update ${targetEntry.role.name} (${targetEntry.email.value}). Reason: ${canUpdateEmailOfTarget.reason.toString()}',
              );
            }
          },
        );
      }
    }
  });
}

Future<void> _testSuccessfulEmailUpdate({
  required WidgetTester tester,
  required UserEntry initiatorEntry,
  required UserEntry targetEntry,
}) async {
  final initiatorUserRole = initiatorEntry.user.role.name;
  final initiatorEmail = initiatorEntry.user.email;
  final initiatorPassword = initiatorEntry.password;

  var targetUserId = targetEntry.user.userId;
  var targetUserRole = targetEntry.user.role.name;
  var targetEmail = targetEntry.user.email;
  var targetPassword = targetEntry.password;

  final isUpdatingEmailOnSelf = initiatorEntry.user.isSameAs(targetEntry.user);

  final updateType = isUpdatingEmailOnSelf ? 'self' : 'other';
  logger.i(
    '[AUTH] $initiatorUserRole ($initiatorEmail) authorized to update $updateType: $targetUserRole ($targetEmail)',
  );

  await tester.startApp();

  await tester.login(
    email: initiatorEntry.email,
    password: initiatorEntry.password,
  );

  final targetUserTile = tester.findUserTileByUserId(targetUserId);
  expect(
    targetUserTile,
    findsOne,
    reason: 'UserTile should be found for $targetUserRole target',
  );

  // Before update, expect the old email
  final targetUserTileWidget = tester.widget<UserTile>(targetUserTile);
  expect(
    targetUserTileWidget.user.email,
    equals(targetEmail),
    reason: 'Target UserTile should show correct email before update',
  );

  final updateEmailIcon = find.descendant(
    of: targetUserTile,
    matching: find.byType(UpdateUserEmailIcon),
  );

  await tester.tap(updateEmailIcon);
  await tester.pumpAndSettle();

  final emailUpdateDialogChild = find.byType(UpdateUserEmailDialogChild);
  expect(
    emailUpdateDialogChild,
    findsOne,
    reason: 'Email update dialog should be shown',
  );

  final confirmInputDialog = find.descendant(
    of: emailUpdateDialogChild,
    matching: find.byType(ConfirmInputDialog),
  );

  expect(
    confirmInputDialog,
    findsOne,
    reason: 'Confirm input dialog should be shown',
  );

  final emailField = find.descendant(
    of: confirmInputDialog,
    matching: find.byType(TextField),
  );

  final newTargetEmail = Email(
    'new_${targetEntry.user.userId.value}@example.com',
  );

  await tester.enterText(emailField, newTargetEmail.value);

  final confirmButton = tester.findConfirmButton();

  logger.i('[UI] Confirming email update for $targetUserRole ($targetEmail)');

  await tester.tap(confirmButton);
  await tester.pumpAndSettle();

  // Ensure UI is settled before searching for updated user tile
  await tester.pumpAndSettle();

  final updatedTargetUserTile = tester.findUserTileByUserId(targetUserId);
  final updatedTargetUserTileWidget = tester.widget<UserTile>(
    updatedTargetUserTile,
  );
  expect(
    updatedTargetUserTileWidget.user.email,
    equals(newTargetEmail),
    reason: 'Target UserTile should show correct email after update',
  );

  logger.i(
    '[RESULT] Email updated: $targetUserRole ($targetEmail) -> ${newTargetEmail.value}',
  );

  await tester.logout();

  final oldTargetEmail = targetEmail;

  logger.i('[LOGIN-OLD] Attempt login with old email: $oldTargetEmail');

  await tester.login(email: oldTargetEmail, password: targetPassword);

  expect(
    find.byType(UserAdministrationView),
    findsNothing,
    reason:
        'Login with old target email should fail after email update for $targetUserRole',
  );

  logger.i(
    '[LOGIN-OLD] Expected failure for $targetUserRole ($oldTargetEmail)',
  );

  logger.i('[LOGIN-NEW] Attempt login with new email: ${newTargetEmail.value}');

  await tester.login(email: newTargetEmail, password: targetPassword);

  expect(
    find.byType(UserAdministrationView),
    findsOne,
    reason:
        'Login with new email should succeed after email update for $targetUserRole',
  );

  logger.i('[LOGIN-NEW] Success for $targetUserRole (${newTargetEmail.value})');

  await tester.logout();
  logger.i('[LOGOUT] $targetUserRole (${newTargetEmail.value})');
}
