import 'package:client/presentation/views/login_view/login_view.dart';
import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:client/presentation/widgets/confirm_dialog.dart';
import 'package:domain/policies/action_authorization_policies/user_administration/user_administration_policy.dart';
import 'package:domain/value_objects/role.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/domain/user_administration_service.dart';
import 'package:test_utils/fixtures/user/user_test_fixture.dart';
import 'package:integration_test/integration_test.dart';
import '../../utils/extensions/widget_tester_extensions.dart';
import '../../utils/integration_test_debug_logger.dart';
import '../../utils/integration_test_server_fixture.dart';

part 'delete_user_extension.dart';

/// Entry point for Delete User integration tests.
///
/// Covers all scenarios for deleting self and other users based on the [ViewUserPolicy] and [DeleteUserPolicy].
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<UserTestFixture> create(Role role) async => await IntegrationTestServerFixture.createUserFixture(role: role);

  group('Delete user integration tests', () {
    group('Analyst tests', () {
      setUp(() async => await IntegrationTestServerFixture.setup());
      tearDown(() async => await IntegrationTestServerFixture.teardown());

      testWidgets('analyst deleting self', (WidgetTester tester) async {
        final self = await create(Role.analyst);
        await tester.deleteUser(initiator: self, target: self);
      });

      testWidgets('analyst deleting user', (WidgetTester tester) async {
        final analyst = await create(Role.analyst);
        final user = await create(Role.user);
        await tester.deleteUser(initiator: analyst, target: user);
      });

      testWidgets('analyst deleting admin', (WidgetTester tester) async {
        final analyst = await create(Role.analyst);
        final admin = await create(Role.admin);
        await tester.deleteUser(initiator: analyst, target: admin);
      });

      testWidgets('analyst deleting other analyst', (WidgetTester tester) async {
        final analyst = await create(Role.analyst);
        final otherAnalyst = await create(Role.analyst);
        await tester.deleteUser(initiator: analyst, target: otherAnalyst);
      });
    });

    group('Admin tests', () {
      setUp(() async => await IntegrationTestServerFixture.setup());
      tearDown(() async => await IntegrationTestServerFixture.teardown());

      testWidgets('analyst deleting self', (WidgetTester tester) async {
        final self = await create(Role.admin);
        await tester.deleteUser(initiator: self, target: self);
      });

      testWidgets('admin deleting user', (WidgetTester tester) async {
        final admin = await create(Role.admin);
        final user = await create(Role.user);
        await tester.deleteUser(initiator: admin, target: user);
      });

      testWidgets('admin deleting other admin', (WidgetTester tester) async {
        final admin = await create(Role.admin);
        final otherAdmin = await create(Role.admin);
        await tester.deleteUser(initiator: admin, target: otherAdmin);
      });

      testWidgets('admin deleting analyst', (WidgetTester tester) async {
        final admin = await create(Role.admin);
        final analyst = await create(Role.analyst);
        await tester.deleteUser(initiator: admin, target: analyst);
      });
    });

    group('User tests', () {
      setUp(() async => await IntegrationTestServerFixture.setup());
      tearDown(() async => await IntegrationTestServerFixture.teardown());

      testWidgets('user deleting self', (WidgetTester tester) async {
        final self = await create(Role.user);
        await tester.deleteUser(initiator: self, target: self);
      });

      testWidgets('user deleting other user', (WidgetTester tester) async {
        final user = await create(Role.user);
        final otherUser = await create(Role.user);
        await tester.deleteUser(initiator: user, target: otherUser);
      });

      testWidgets('user deleting admin', (WidgetTester tester) async {
        final user = await create(Role.user);
        final admin = await create(Role.admin);
        await tester.deleteUser(initiator: user, target: admin);
      });

      testWidgets('user deleting analyst', (WidgetTester tester) async {
        final user = await create(Role.user);
        final analyst = await create(Role.analyst);
        await tester.deleteUser(initiator: user, target: analyst);
      });
    });
  });
}
