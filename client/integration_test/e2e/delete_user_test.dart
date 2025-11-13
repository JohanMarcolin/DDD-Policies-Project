import 'package:client/infrastructure/apis/test_api.dart';
import 'package:client/presentation/views/login_view/login_view.dart';
import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:client/presentation/widgets/confirm_dialog.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:domain/value_objects/role.dart';
import 'package:flutter_test/flutter_test.dart';
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

    final viewUserPolicy = ViewUserPolicy();
    final deleteUserPolicy = DeleteUserPolicy();

    for (final role in Role.values) {
      testWidgets('${role.name} deleting self scenario', (WidgetTester tester) async {
        final self = await IntegrationTestServerFixture.createUserFixture(role: role);

        final viewSelf = viewUserPolicy.authorize(self.user, self.user);
        switch (viewSelf) {
          case Authorized():
            await tester.assertUserTileIsVisible(initiator: self, target: self);
          case Unauthorized():
            await tester.assertUserTileIsNotVisible(initiator: self, target: self);
            return;
        }

        final deleteSelf = deleteUserPolicy.authorize(self.user, self.user);
        switch (deleteSelf) {
          case Authorized():
            await _assertDeleteUserSucceeds(tester: tester, initiator: self, target: self);
          case Unauthorized():
            await _assertDeleteUserBlocked(tester: tester, initiator: self, target: self);
        }
      });
      for (final targetRole in Role.values) {
        testWidgets('${role.name} deleting ${targetRole.name} scenario', (WidgetTester tester) async {
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

          final deleteTarget = deleteUserPolicy.authorize(initiator.user, target.user);
          switch (deleteTarget) {
            case Authorized():
              await _assertDeleteUserSucceeds(tester: tester, initiator: initiator, target: target);
            case Unauthorized():
              await _assertDeleteUserBlocked(tester: tester, initiator: initiator, target: target);
          }
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
  final isDeletingSelf = initiator.user.isSameAs(target.user);
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

Future<void> _assertDeleteUserBlocked({
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
