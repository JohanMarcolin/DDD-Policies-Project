import 'package:client/presentation/views/login_view/login_view.dart';
import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:test_utils/fixtures/user/user_test_fixture.dart';
import '../../utils/extensions/widget_finder_extensions.dart';
import '../../utils/extensions/widget_tester_extensions.dart';
import '../../utils/integration_test_server_fixture.dart';

part 'user_authentication_extension.dart';

/// Entry point for User Authentication integration tests.
///
/// Covers login, session persistence, and logout scenarios for all user roles.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('User Authentication Scenario', () {
    setUpAll(() async => await IntegrationTestServerFixture.setup());

    tearDownAll(() async => await IntegrationTestServerFixture.teardown());

    testWidgets('should login, persist session, and logout successfully', (WidgetTester tester) async {
      for (final user in await IntegrationTestServerFixture.createAllUserFixtures()) {
        await tester.testLogin(user);
        await tester.testSessionPersistence(user);
        await tester.testLogout(user);
      }
    });
  });
}
