import 'package:client/infrastructure/apis/http_api.dart';
import 'package:client/infrastructure/apis/test_api.dart';
import 'package:client/infrastructure/services/auth_token_service.dart';
import 'package:client/presentation/views/login_view/login_view.dart';
import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:server/test/utils/factories/test_server_factory.dart';

import '../utils/extensions/widget_finder_extension.dart';
import '../utils/extensions/widget_tester_extension.dart';
import '../utils/test_server_fixture.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('User Authentication Lifecycle', () {
    setUpAll(() async => await TestServerFixture.setup());

    tearDownAll(() async => await TestServerFixture.teardown());

    testWidgets('should login, persist session, and logout successfully', (
      WidgetTester tester,
    ) async {
      for (final user in await TestServerFixture.createAllUserFixtures()) {
        final roleName = user.role.name;

        await tester.startApp();
        await tester.login(email: user.email, password: user.password);
        final userAdministrationView = find.byType(UserAdministrationView);

        expect(
          userAdministrationView,
          findsOne,
          reason:
              'Should show UserAdministrationView after successful login for $roleName',
        );
        expect(
          userAdministrationView.findDescendant(UserList),
          findsOne,
          reason:
              'Should show UserList in UserAdministrationView for $roleName',
        );

        await tester.startApp();
        expect(
          find.byType(LoginView),
          findsNothing,
          reason:
              'LoginView should not be shown after app restart for $roleName',
        );
        expect(
          find.byType(UserAdministrationView),
          findsOne,
          reason:
              'Should show UserAdministrationView directly after app restart for $roleName',
        );

        await tester.tap(find.byIcon(Icons.logout));
        await tester.pumpAndSettle();
        expect(
          find.byType(LoginView),
          findsOne,
          reason: 'Should show LoginView after logout for $roleName',
        );
      }
    });
  });
}
