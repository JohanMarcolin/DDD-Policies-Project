import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:domain/value_objects/role.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/user_test_fixture.dart';
import 'package:integration_test/integration_test.dart';
import '../integration_test_server_fixture.dart';
import '../utils/extensions/widget_finder_extensions.dart';
import '../utils/extensions/widget_tester_extensions.dart';

/// Entry point for View User integration tests.
///
/// Covers all scenarios for viewing self and other users based on the [ViewUserPolicy].
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('View User Scenario', () {
    setUp(() async => await IntegrationTestServerFixture.setup());
    tearDown(() async => await IntegrationTestServerFixture.teardown());

    final viewUserPolicy = ViewUserPolicy();

    for (final role in Role.values) {
      testWidgets('${role.name} viewing self scenario', (WidgetTester tester) async {
        final self = await IntegrationTestServerFixture.createUserFixture(role: role);

        final viewSelf = viewUserPolicy.authorize(self.user, self.user);
        switch (viewSelf) {
          case Authorized():
            await _assertViewUserSucceeds(tester: tester, initiator: self, target: self);
          case Unauthorized():
            await _assertViewUserBlocked(tester: tester, initiator: self, target: self);
        }
      });
      for (final targetRole in Role.values) {
        testWidgets('${role.name} viewing ${targetRole.name} scenario', (WidgetTester tester) async {
          final initiator = await IntegrationTestServerFixture.createUserFixture(role: role);
          final target = await IntegrationTestServerFixture.createUserFixture(role: targetRole);

          final viewTarget = viewUserPolicy.authorize(initiator.user, target.user);
          switch (viewTarget) {
            case Authorized():
              await _assertViewUserSucceeds(tester: tester, initiator: initiator, target: target);
            case Unauthorized():
              await _assertViewUserBlocked(tester: tester, initiator: initiator, target: target);
          }
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

Future<void> _assertViewUserBlocked({
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
  final targetUserRole = target.user.role.name;

  await tester.startApp();
  await tester.login(email: initiator.email, password: initiator.password);

  final userAdministrationView = find.byType(UserAdministrationView);
  expect(userAdministrationView, findsOne, reason: 'Should show UserAdministrationView after login');

  final userList = userAdministrationView.findDescendant(UserList);
  expect(userList, findsOne, reason: 'Should show UserList in UserAdministrationView');

  final targetUserTile = userList.findDescendantMatching(
    find.byWidgetPredicate((widget) => widget is UserTile && widget.user.isSameAs(target.user)),
  );
  expect(
    targetUserTile,
    shouldFind ? findsOne : findsNothing,
    reason: shouldFind
        ? 'UserTile should be found for $targetUserRole target'
        : 'UserTile should not be found for $targetUserRole target',
  );

  await tester.logout();
}
