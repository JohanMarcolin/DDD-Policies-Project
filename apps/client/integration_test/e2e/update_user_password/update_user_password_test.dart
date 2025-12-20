import 'package:client/presentation/views/login_view/login_view.dart';
import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:client/presentation/widgets/confirm_input_dialog.dart';
import 'package:domain/policies/action_authorization_policies/user_administration/user_administration_policy.dart';
import 'package:domain/value_objects/password.dart';
import 'package:domain/value_objects/role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/domain/user_administration_service.dart';
import 'package:test_utils/fixtures/user/user_test_fixture.dart';
import 'package:integration_test/integration_test.dart';
import '../../utils/extensions/widget_tester_extensions.dart';
import '../../utils/integration_test_server_fixture.dart';

part 'update_user_password_extension.dart';

/// Entry point for Update user password integration tests.
///
/// Covers all scenarios for updating password on self and other users based on the [ViewUserPolicy] and [UpdateUserPasswordPolicy].
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Update user password integration tests', () {
    group('Analyst tests', () {
      setUp(() async => await IntegrationTestServerFixture.setup());
      tearDown(() async => await IntegrationTestServerFixture.teardown());

      testWidgets('analyst updating password on self', (WidgetTester tester) async {
        final self = await IntegrationTestServerFixture.createUserFixture(role: Role.analyst);
        await tester.updateUserPassword(initiator: self, target: self);
      });

      testWidgets('analyst updating password on user', (WidgetTester tester) async {
        final analyst = await IntegrationTestServerFixture.createUserFixture(role: Role.analyst);
        final user = await IntegrationTestServerFixture.createUserFixture(role: Role.user);
        await tester.updateUserPassword(initiator: analyst, target: user);
      });

      testWidgets('analyst updating password on admin', (WidgetTester tester) async {
        final analyst = await IntegrationTestServerFixture.createUserFixture(role: Role.analyst);
        final admin = await IntegrationTestServerFixture.createUserFixture(role: Role.admin);
        await tester.updateUserPassword(initiator: analyst, target: admin);
      });

      testWidgets('analyst updating password on other analyst', (WidgetTester tester) async {
        final analyst = await IntegrationTestServerFixture.createUserFixture(role: Role.analyst);
        final otherAnalyst = await IntegrationTestServerFixture.createUserFixture(role: Role.analyst);
        await tester.updateUserPassword(initiator: analyst, target: otherAnalyst);
      });
    });

    group('Admin tests', () {
      setUp(() async => await IntegrationTestServerFixture.setup());
      tearDown(() async => await IntegrationTestServerFixture.teardown());

      testWidgets('analyst updating password on self', (WidgetTester tester) async {
        final self = await IntegrationTestServerFixture.createUserFixture(role: Role.admin);
        await tester.updateUserPassword(initiator: self, target: self);
      });

      testWidgets('admin updating password on user', (WidgetTester tester) async {
        final admin = await IntegrationTestServerFixture.createUserFixture(role: Role.admin);
        final user = await IntegrationTestServerFixture.createUserFixture(role: Role.user);
        await tester.updateUserPassword(initiator: admin, target: user);
      });

      testWidgets('admin updating password on other admin', (WidgetTester tester) async {
        final admin = await IntegrationTestServerFixture.createUserFixture(role: Role.admin);
        final otherAdmin = await IntegrationTestServerFixture.createUserFixture(role: Role.admin);
        await tester.updateUserPassword(initiator: admin, target: otherAdmin);
      });

      testWidgets('admin updating password on analyst', (WidgetTester tester) async {
        final admin = await IntegrationTestServerFixture.createUserFixture(role: Role.admin);
        final analyst = await IntegrationTestServerFixture.createUserFixture(role: Role.analyst);
        await tester.updateUserPassword(initiator: admin, target: analyst);
      });
    });

    group('User tests', () {
      setUp(() async => await IntegrationTestServerFixture.setup());
      tearDown(() async => await IntegrationTestServerFixture.teardown());

      testWidgets('user updating password on self', (WidgetTester tester) async {
        final self = await IntegrationTestServerFixture.createUserFixture(role: Role.user);
        await tester.updateUserPassword(initiator: self, target: self);
      });

      testWidgets('user updating password on other user', (WidgetTester tester) async {
        final user = await IntegrationTestServerFixture.createUserFixture(role: Role.user);
        final otherUser = await IntegrationTestServerFixture.createUserFixture(role: Role.user);
        await tester.updateUserPassword(initiator: user, target: otherUser);
      });

      testWidgets('user updating password on admin', (WidgetTester tester) async {
        final user = await IntegrationTestServerFixture.createUserFixture(role: Role.user);
        final admin = await IntegrationTestServerFixture.createUserFixture(role: Role.admin);
        await tester.updateUserPassword(initiator: user, target: admin);
      });

      testWidgets('user updating password on analyst', (WidgetTester tester) async {
        final user = await IntegrationTestServerFixture.createUserFixture(role: Role.user);
        final analyst = await IntegrationTestServerFixture.createUserFixture(role: Role.analyst);
        await tester.updateUserPassword(initiator: user, target: analyst);
      });
    });
  });
}
