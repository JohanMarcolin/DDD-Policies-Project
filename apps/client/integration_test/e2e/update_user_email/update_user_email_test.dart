import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:client/presentation/widgets/confirm_input_dialog.dart';
import 'package:domain/policies/action_authorization_policies/user_administration/user_administration_policy.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/id.dart';
import 'package:domain/value_objects/role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:test_utils/domain/user_administration_service.dart';
import 'package:test_utils/fixtures/user/user_test_fixture.dart';
import 'package:test_utils/mocks/mock_user_credentials.dart';
import '../../utils/extensions/widget_tester_extensions.dart';
import '../../utils/integration_test_server_fixture.dart';

part 'update_user_email_tester_extension.dart';

/// Entry point for Update user email integration tests.
///
/// Covers all scenarios for updating email on self and other users based on the [ViewUserPolicy] and [UpdateUserEmailPolicy].
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Update user email integration tests', () {
    group('Analyst tests', () {
      setUp(() async => await IntegrationTestServerFixture.setup());
      tearDown(() async => await IntegrationTestServerFixture.teardown());

      testWidgets('analyst updating email on self', (WidgetTester tester) async {
        final self = await IntegrationTestServerFixture.createUserFixture(role: Role.analyst);
        await tester.updateUserEmail(initiator: self, target: self);
      });

      testWidgets('analyst updating email on user', (WidgetTester tester) async {
        final analyst = await IntegrationTestServerFixture.createUserFixture(role: Role.analyst);
        final user = await IntegrationTestServerFixture.createUserFixture(role: Role.user);
        await tester.updateUserEmail(initiator: analyst, target: user);
      });

      testWidgets('analyst updating email on admin', (WidgetTester tester) async {
        final analyst = await IntegrationTestServerFixture.createUserFixture(role: Role.analyst);
        final admin = await IntegrationTestServerFixture.createUserFixture(role: Role.admin);
        await tester.updateUserEmail(initiator: analyst, target: admin);
      });

      testWidgets('analyst updating email on other analyst', (WidgetTester tester) async {
        final analyst = await IntegrationTestServerFixture.createUserFixture(role: Role.analyst);
        final otherAnalyst = await IntegrationTestServerFixture.createUserFixture(role: Role.analyst);
        await tester.updateUserEmail(initiator: analyst, target: otherAnalyst);
      });
    });

    group('Admin tests', () {
      setUp(() async => await IntegrationTestServerFixture.setup());
      tearDown(() async => await IntegrationTestServerFixture.teardown());

      testWidgets('analyst updating email on self', (WidgetTester tester) async {
        final self = await IntegrationTestServerFixture.createUserFixture(role: Role.analyst);
        await tester.updateUserEmail(initiator: self, target: self);
      });

      testWidgets('admin updating email on user', (WidgetTester tester) async {
        final admin = await IntegrationTestServerFixture.createUserFixture(role: Role.admin);
        final user = await IntegrationTestServerFixture.createUserFixture(role: Role.user);
        await tester.updateUserEmail(initiator: admin, target: user);
      });

      testWidgets('admin updating email on other admin', (WidgetTester tester) async {
        final admin = await IntegrationTestServerFixture.createUserFixture(role: Role.admin);
        final otherAdmin = await IntegrationTestServerFixture.createUserFixture(role: Role.admin);
        await tester.updateUserEmail(initiator: admin, target: otherAdmin);
      });

      testWidgets('admin updating email on analyst', (WidgetTester tester) async {
        final admin = await IntegrationTestServerFixture.createUserFixture(role: Role.admin);
        final analyst = await IntegrationTestServerFixture.createUserFixture(role: Role.analyst);
        await tester.updateUserEmail(initiator: admin, target: analyst);
      });
    });

    group('User tests', () {
      setUp(() async => await IntegrationTestServerFixture.setup());
      tearDown(() async => await IntegrationTestServerFixture.teardown());

      testWidgets('user updating email on self', (WidgetTester tester) async {
        final self = await IntegrationTestServerFixture.createUserFixture(role: Role.user);
        await tester.updateUserEmail(initiator: self, target: self);
      });

      testWidgets('user updating email on other user', (WidgetTester tester) async {
        final user = await IntegrationTestServerFixture.createUserFixture(role: Role.user);
        final otherUser = await IntegrationTestServerFixture.createUserFixture(role: Role.user);
        await tester.updateUserEmail(initiator: user, target: otherUser);
      });

      testWidgets('user updating email on admin', (WidgetTester tester) async {
        final user = await IntegrationTestServerFixture.createUserFixture(role: Role.user);
        final admin = await IntegrationTestServerFixture.createUserFixture(role: Role.admin);
        await tester.updateUserEmail(initiator: user, target: admin);
      });

      testWidgets('user updating email on analyst', (WidgetTester tester) async {
        final user = await IntegrationTestServerFixture.createUserFixture(role: Role.user);
        final analyst = await IntegrationTestServerFixture.createUserFixture(role: Role.analyst);
        await tester.updateUserEmail(initiator: user, target: analyst);
      });
    });
  });
}
