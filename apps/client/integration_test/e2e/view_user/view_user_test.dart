import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:domain/policies/action_authorization_policies/user_administration/user_administration_policy.dart';
import 'package:domain/value_objects/role.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/domain/user_administration_service.dart';
import 'package:test_utils/fixtures/user/user_test_fixture.dart';
import 'package:integration_test/integration_test.dart';
import '../../utils/extensions/widget_finder_extensions.dart';
import '../../utils/extensions/widget_tester_extensions.dart';
import '../../utils/integration_test_server_fixture.dart';

part 'view_user_extension.dart';

/// Entry point for View User integration tests.
///
/// Covers all scenarios for viewing self and other users based on the [ViewUserPolicy].
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('View User integration tests', () {
    group('Analyst tests', () {
      setUp(() async => await IntegrationTestServerFixture.setup());
      tearDown(() async => await IntegrationTestServerFixture.teardown());

      testWidgets('analyst viewing self', (WidgetTester tester) async {
        final self = await IntegrationTestServerFixture.createUserFixture(role: Role.analyst);
        await tester.viewUser(initiator: self, target: self);
      });

      testWidgets('analyst viewing user', (WidgetTester tester) async {
        final analyst = await IntegrationTestServerFixture.createUserFixture(role: Role.analyst);
        final user = await IntegrationTestServerFixture.createUserFixture(role: Role.user);
        await tester.viewUser(initiator: analyst, target: user);
      });

      testWidgets('analyst viewing admin', (WidgetTester tester) async {
        final analyst = await IntegrationTestServerFixture.createUserFixture(role: Role.analyst);
        final admin = await IntegrationTestServerFixture.createUserFixture(role: Role.admin);
        await tester.viewUser(initiator: analyst, target: admin);
      });

      testWidgets('analyst viewing other analyst', (WidgetTester tester) async {
        final analyst = await IntegrationTestServerFixture.createUserFixture(role: Role.analyst);
        final otherAnalyst = await IntegrationTestServerFixture.createUserFixture(role: Role.analyst);
        await tester.viewUser(initiator: analyst, target: otherAnalyst);
      });
    });

    group('Admin tests', () {
      setUp(() async => await IntegrationTestServerFixture.setup());
      tearDown(() async => await IntegrationTestServerFixture.teardown());

      testWidgets('analyst viewing self', (WidgetTester tester) async {
        final self = await IntegrationTestServerFixture.createUserFixture(role: Role.admin);
        await tester.viewUser(initiator: self, target: self);
      });

      testWidgets('admin viewing user', (WidgetTester tester) async {
        final admin = await IntegrationTestServerFixture.createUserFixture(role: Role.admin);
        final user = await IntegrationTestServerFixture.createUserFixture(role: Role.user);
        await tester.viewUser(initiator: admin, target: user);
      });

      testWidgets('admin viewing other admin', (WidgetTester tester) async {
        final admin = await IntegrationTestServerFixture.createUserFixture(role: Role.admin);
        final otherAdmin = await IntegrationTestServerFixture.createUserFixture(role: Role.admin);
        await tester.viewUser(initiator: admin, target: otherAdmin);
      });

      testWidgets('admin viewing analyst', (WidgetTester tester) async {
        final admin = await IntegrationTestServerFixture.createUserFixture(role: Role.admin);
        final analyst = await IntegrationTestServerFixture.createUserFixture(role: Role.analyst);
        await tester.viewUser(initiator: admin, target: analyst);
      });
    });

    group('User tests', () {
      setUp(() async => await IntegrationTestServerFixture.setup());
      tearDown(() async => await IntegrationTestServerFixture.teardown());

      testWidgets('user viewing self', (WidgetTester tester) async {
        final self = await IntegrationTestServerFixture.createUserFixture(role: Role.user);
        await tester.viewUser(initiator: self, target: self);
      });

      testWidgets('user viewing other user', (WidgetTester tester) async {
        final user = await IntegrationTestServerFixture.createUserFixture(role: Role.user);
        final otherUser = await IntegrationTestServerFixture.createUserFixture(role: Role.user);
        await tester.viewUser(initiator: user, target: otherUser);
      });

      testWidgets('user viewing admin', (WidgetTester tester) async {
        final user = await IntegrationTestServerFixture.createUserFixture(role: Role.user);
        final admin = await IntegrationTestServerFixture.createUserFixture(role: Role.admin);
        await tester.viewUser(initiator: user, target: admin);
      });

      testWidgets('user viewing analyst', (WidgetTester tester) async {
        final user = await IntegrationTestServerFixture.createUserFixture(role: Role.user);
        final analyst = await IntegrationTestServerFixture.createUserFixture(role: Role.analyst);
        await tester.viewUser(initiator: user, target: analyst);
      });
    });
  });
}
