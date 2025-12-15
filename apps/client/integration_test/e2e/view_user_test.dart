import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:domain/policies/action_authorization_policies/user_administration/user_administration_policy.dart';
import 'package:domain/value_objects/role.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/domain/user_administration_service.dart';
import 'package:test_utils/fixtures/user/user_test_fixture.dart';
import 'package:integration_test/integration_test.dart';
import '../utils/extensions/widget_finder_extensions.dart';
import '../utils/extensions/widget_tester_extensions.dart';
import '../utils/integration_test_server_fixture.dart';

/// Entry point for View User integration tests.
///
/// Covers all scenarios for viewing self and other users based on the [ViewUserPolicy].
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('View User Scenario', () {
    setUp(() async => await IntegrationTestServerFixture.setup());
    tearDown(() async => await IntegrationTestServerFixture.teardown());

    final userAdministrationService = createStubbedUserAdministrationService();

    for (final initiatorRole in Role.values) {
      final initiatorRoleName = initiatorRole.name;

      testWidgets('$initiatorRoleName viewing self scenario', (WidgetTester tester) async {
        final self = await IntegrationTestServerFixture.createUserFixture(role: initiatorRole);

        await userAdministrationService.authorizeViewUser(
          initiator: self.user,
          target: self.user,
          onAuthorized: () async => await _assertViewUserSucceeds(tester: tester, initiator: self, target: self),
          onUnauthorized: (_) async {
            await _assertViewUserIsBlocked(tester: tester, initiator: self, target: self);
            return;
          },
        );
      });
      for (final targetRole in Role.values) {
        testWidgets('$initiatorRoleName viewing ${targetRole.name} scenario', (WidgetTester tester) async {
          final initiator = await IntegrationTestServerFixture.createUserFixture(role: initiatorRole);
          final target = await IntegrationTestServerFixture.createUserFixture(role: targetRole);

          await userAdministrationService.authorizeViewUser(
            initiator: initiator.user,
            target: target.user,
            onAuthorized: () async =>
                await _assertViewUserSucceeds(tester: tester, initiator: initiator, target: target),
            onUnauthorized: (_) async =>
                await _assertViewUserIsBlocked(tester: tester, initiator: initiator, target: target),
          );
        });
      }
    }
  });
}

Future<void> _assertViewUserSucceeds({
  required WidgetTester tester,
  required UserTestFixture initiator,
  required UserTestFixture target,
}) async {
  await _assertViewUser(tester: tester, initiator: initiator, target: target, shouldFind: true);
}

Future<void> _assertViewUserIsBlocked({
  required WidgetTester tester,
  required UserTestFixture initiator,
  required UserTestFixture target,
}) async {
  await _assertViewUser(tester: tester, initiator: initiator, target: target, shouldFind: false);
}

Future<void> _assertViewUser({
  required WidgetTester tester,
  required UserTestFixture initiator,
  required UserTestFixture target,
  required bool shouldFind,
}) async {
  await tester.startApp();
  await tester.login(email: initiator.email, password: initiator.password);

  final userAdministrationView = find.byType(UserAdministrationView);
  expect(userAdministrationView, findsOne, reason: 'Should show UserAdministrationView after login');

  final userList = userAdministrationView.findDescendant(UserList);
  expect(userList, findsOne, reason: 'Should show UserList in UserAdministrationView');

  final targetUserTile = userList.findDescendantMatching(
    find.byWidgetPredicate((widget) => widget is UserTile && widget.user.isSameAs(target.user)),
  );

  final targetUserRole = target.user.role.name;

  expect(
    targetUserTile,
    shouldFind ? findsOne : findsNothing,
    reason: shouldFind
        ? 'UserTile should be found for $targetUserRole target'
        : 'UserTile should not be found for $targetUserRole target',
  );

  await tester.logout();
}
