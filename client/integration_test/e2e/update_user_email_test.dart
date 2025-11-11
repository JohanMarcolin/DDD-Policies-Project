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

    final canViewUserPolicy = ViewUserPolicy();
    final updateUserEmailPolicy = UpdateUserEmailPolicy();

    for (final initiatorRole in Role.values) {
      testWidgets('${initiatorRole.name} updating email on self lifecycle', (
        WidgetTester tester,
      ) async {
        final initiatorEntry = await testApi.createUserEntry(
          role: initiatorRole,
        );

        final viewSelf = canViewUserPolicy.authorize(
          initiatorEntry.user,
          initiatorEntry.user,
        );
        switch (viewSelf) {
          case Authorized():
            await _onViewUserAuthorized(
              tester: tester,
              initiatorEntry: initiatorEntry,
              targetEntry: initiatorEntry,
            );
          case Unauthorized():
            await _onViewUserUnauthorized(
              tester: tester,
              initiatorEntry: initiatorEntry,
              targetEntry: initiatorEntry,
            );
            return;
        }

        final updateEmailOnSelf = updateUserEmailPolicy.authorize(
          initiatorEntry.user,
          initiatorEntry.user,
        );
        switch (updateEmailOnSelf) {
          case Authorized():
            await _onUpdateUserEmailAuthorized(
              tester: tester,
              initiatorEntry: initiatorEntry,
              targetEntry: initiatorEntry,
            );
          case Unauthorized():
            await _onUpdateUserEmailUnauthorized(
              tester: tester,
              initiatorEntry: initiatorEntry,
              targetEntry: initiatorEntry,
            );
        }
      });
      for (final targetRole in Role.values) {
        testWidgets(
          '${initiatorRole.name} updating email on ${targetRole.name} lifecycle',
          (WidgetTester tester) async {
            final initiatorEntry = await testApi.createUserEntry(
              role: initiatorRole,
            );
            final targetEntry = await testApi.createUserEntry(role: targetRole);

            final viewTarget = canViewUserPolicy.authorize(
              initiatorEntry.user,
              targetEntry.user,
            );
            switch (viewTarget) {
              case Authorized():
                await _onViewUserAuthorized(
                  tester: tester,
                  initiatorEntry: initiatorEntry,
                  targetEntry: targetEntry,
                );
              case Unauthorized():
                await _onViewUserUnauthorized(
                  tester: tester,
                  initiatorEntry: initiatorEntry,
                  targetEntry: targetEntry,
                );
                return;
            }

            final updateEmailOfTarget = updateUserEmailPolicy.authorize(
              initiatorEntry.user,
              targetEntry.user,
            );
            switch (updateEmailOfTarget) {
              case Authorized():
                await _onUpdateUserEmailAuthorized(
                  tester: tester,
                  initiatorEntry: initiatorEntry,
                  targetEntry: targetEntry,
                );
              case Unauthorized():
                await _onUpdateUserEmailUnauthorized(
                  tester: tester,
                  initiatorEntry: initiatorEntry,
                  targetEntry: targetEntry,
                );
            }
          },
        );
      }
    }
  });
}

Future<void> _onViewUserAuthorized({
  required WidgetTester tester,
  required UserEntry initiatorEntry,
  required UserEntry targetEntry,
}) async {
  var targetUserId = targetEntry.user.userId;
  var targetUserRole = targetEntry.user.role.name;

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

  await tester.logout();
}

Future<void> _onViewUserUnauthorized({
  required WidgetTester tester,
  required UserEntry initiatorEntry,
  required UserEntry targetEntry,
}) async {
  var targetUserId = targetEntry.user.userId;
  var targetUserRole = targetEntry.user.role.name;

  await tester.startApp();

  await tester.login(
    email: initiatorEntry.email,
    password: initiatorEntry.password,
  );

  final targetUserTile = tester.findUserTileByUserId(targetUserId);
  expect(
    targetUserTile,
    findsNothing,
    reason: 'UserTile should not be found for $targetUserRole target',
  );

  await tester.logout();
}

Future<void> _onUpdateUserEmailAuthorized({
  required WidgetTester tester,
  required UserEntry initiatorEntry,
  required UserEntry targetEntry,
}) async {
  var targetUserId = targetEntry.user.userId;
  var targetUserRole = targetEntry.user.role.name;
  var targetEmail = targetEntry.user.email;
  var targetPassword = targetEntry.password;

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

  final updatedTargetUserTile = tester.findUserTileByUserId(targetUserId);
  final updatedTargetUserTileWidget = tester.widget<UserTile>(
    updatedTargetUserTile,
  );
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
    reason:
        'Login with old target email should fail after email update for $targetUserRole',
  );

  await tester.login(email: newTargetEmail, password: targetPassword);

  expect(
    find.byType(UserAdministrationView),
    findsOne,
    reason:
        'Login with new email should succeed after email update for $targetUserRole',
  );

  await tester.logout();
}

Future<void> _onUpdateUserEmailUnauthorized({
  required WidgetTester tester,
  required UserEntry initiatorEntry,
  required UserEntry targetEntry,
}) async {
  var targetUserId = targetEntry.user.userId;
  var targetUserRole = targetEntry.user.role.name;

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

  final updateEmailIcon = find.descendant(
    of: targetUserTile,
    matching: find.byType(UpdateUserEmailIcon),
  );

  await tester.tap(updateEmailIcon);
  await tester.pumpAndSettle();

  final emailUpdateDialogChild = find.byType(UpdateUserEmailDialogChild);
  expect(
    emailUpdateDialogChild,
    findsNothing,
    reason: 'Email update dialog should not be shown',
  );

  await tester.logout();
}
