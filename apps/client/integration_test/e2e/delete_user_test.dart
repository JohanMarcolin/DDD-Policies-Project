import 'package:client/presentation/views/login_view/login_view.dart';
import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:client/presentation/widgets/confirm_dialog.dart';
import 'package:domain/policies/action_authorization_policies/user_administration/user_administration_policy.dart';
import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:domain/value_objects/role.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/domain/user_administration_service.dart';
import 'package:test_utils/fixtures/user/user_test_fixture.dart';
import 'package:integration_test/integration_test.dart';
import '../utils/extensions/widget_tester_extensions.dart';
import '../utils/integration_test_server_fixture.dart';

/// Entry point for Delete User integration tests.
///
/// Covers all scenarios for deleting self and other users based on the [ViewUserPolicy] and [DeleteUserPolicy].
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Delete User Scenario', () {
    setUp(() async => await IntegrationTestServerFixture.setup());
    tearDown(() async => await IntegrationTestServerFixture.teardown());

    final UserAdministrationService userAdministrationService = createStubbedUserAdministrationService();

    for (final initiatorRole in Role.values) {
      testWidgets('${initiatorRole.name} deleting self scenario', (WidgetTester tester) async {
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

        /// If the initiator cannot view themselves, they cannot delete themselves.
        if (!canViewSelf) return;

        await userAdministrationService.authorizeDeleteUser(
          initiator: self.user,
          target: self.user,
          onAuthorized: () async => await _assertDeleteUserSucceeds(tester: tester, initiator: self, target: self),
          onUnauthorized: (_) async => await _assertDeleteUserIsBlocked(tester: tester, initiator: self, target: self),
        );
      });

      for (final targetRole in Role.values) {
        testWidgets('${initiatorRole.name} deleting ${targetRole.name} scenario', (WidgetTester tester) async {
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

          /// If the initiator cannot view the target, they cannot delete the target.
          if (!canViewTarget) return;

          await userAdministrationService.authorizeDeleteUser(
            initiator: initiator.user,
            target: target.user,
            onAuthorized: () async =>
                await _assertDeleteUserSucceeds(tester: tester, initiator: initiator, target: target),
            onUnauthorized: (_) async =>
                await _assertDeleteUserIsBlocked(tester: tester, initiator: initiator, target: target),
          );
        });
      }
    }
  });
}

Future<void> _assertDeleteUserSucceeds({
  required WidgetTester tester,
  required UserTestFixture initiator,
  required UserTestFixture target,
}) async {
  final targetUserRole = target.user.role.name;

  await tester.startApp();
  await tester.login(email: initiator.user.email, password: initiator.password);

  expect(find.byType(UserAdministrationView), findsOne);

  final targetUserTile = tester.findUserTileByUserId(target.user.userId);
  expect(targetUserTile, findsOne, reason: 'UserTile should be found for target $targetUserRole');

  final deleteUserIcon = find.descendant(of: targetUserTile, matching: find.byType(DeleteUserIcon));
  await tester.tap(deleteUserIcon);
  await tester.pumpAndSettle();

  final deleteUserDialogChild = find.byType(DeleteUserDialogChild);
  expect(deleteUserDialogChild, findsOne, reason: 'DeleteUserDialogChild should be shown');

  final confirmDialog = find.descendant(of: deleteUserDialogChild, matching: find.byType(ConfirmDialog));
  expect(confirmDialog, findsOne);

  final confirmButton = tester.findConfirmButton();
  await tester.tap(confirmButton);
  await tester.pumpAndSettle();

  final isDeletingSelf = initiator.user.isSameAs(target.user);

  if (isDeletingSelf) {
    expect(
      find.byType(LoginView),
      findsOne,
      reason: 'Should navigate to LoginView after deletion of target $targetUserRole',
    );

    await tester.login(email: target.user.email, password: target.password);
    expect(
      find.byType(UserAdministrationView),
      findsNothing,
      reason: 'Should not be able to login with deleted target $targetUserRole',
    );
  } else {
    expect(targetUserTile, findsNothing, reason: 'Target $targetUserRole should no longer be listed after deletion');
  }
}

Future<void> _assertDeleteUserIsBlocked({
  required WidgetTester tester,
  required UserTestFixture initiator,
  required UserTestFixture target,
}) async {
  final targetUserRole = target.user.role.name;

  await tester.startApp();
  await tester.login(email: initiator.email, password: initiator.password);

  final targetUserTile = tester.findUserTileByUserId(target.user.userId);
  expect(targetUserTile, findsOne, reason: 'UserTile should be found for $targetUserRole target');

  final deleteUserIcon = find.descendant(of: targetUserTile, matching: find.byType(DeleteUserIcon));
  await tester.tap(deleteUserIcon);
  await tester.pumpAndSettle();

  final deleteUserDialogChild = find.byType(DeleteUserDialogChild);
  expect(deleteUserDialogChild, findsNothing, reason: 'Delete user dialog should not be shown');

  await tester.logout();
}
