import 'package:client/infrastructure/apis/http_api.dart';
import 'package:client/infrastructure/apis/test_api.dart';
import 'package:client/infrastructure/services/auth_token_service.dart';
import 'package:client/presentation/views/login_view/login_view.dart';
import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:server/test/utils/factories/test_server_factory.dart';
import 'package:logger/logger.dart';

import '../utils/extensions/widget_finder_extension.dart';
import '../utils/extensions/widget_tester_extension.dart';

final logger = Logger();

late TestApi testApi;
late AuthTokenService authTokenService;
late List<UserEntry> userEntries;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('User Authentication Lifecycle', () {
    setUpAll(() async {
      await TestServerFactory.start(enableTestRoutes: true);
      HttpApi.baseUrl = TestServerFactory.baseUrl;
      testApi = TestApi();
      authTokenService = AuthTokenService();
      userEntries = await testApi.createAllUserPairs();
    });

    tearDownAll(() async {
      await testApi.deleteAllTestUsers();
      await TestServerFactory.stop();
      await authTokenService.clearTokens();
    });

    testWidgets('should login, persist session, and logout successfully', (
      WidgetTester tester,
    ) async {
      for (final entry in userEntries) {
        final userRole = entry.user.role.name;
        final email = entry.user.email;
        final password = entry.password;

        logger.i('Logging in as $userRole');

        await tester.startApp();
        await tester.login(email: email, password: password);
        final userAdministrationView = find.byType(UserAdministrationView);

        expect(
          userAdministrationView,
          findsOne,
          reason:
              'Should show UserAdministrationView after successful login for $userRole',
        );
        expect(
          userAdministrationView.findDescendant(UserList),
          findsOne,
          reason:
              'Should show UserList in UserAdministrationView for $userRole',
        );

        logger.i('Login successful for $userRole');

        logger.i('Persisting session for $userRole');

        await tester.startApp();
        expect(
          find.byType(LoginView),
          findsNothing,
          reason:
              'LoginView should not be shown after app restart for $userRole',
        );
        expect(
          find.byType(UserAdministrationView),
          findsOne,
          reason:
              'Should show UserAdministrationView directly after app restart for $userRole',
        );

        logger.i('Session persisted successfully for $userRole');

        logger.i('Logging out as $userRole');

        await tester.tap(find.byIcon(Icons.logout));
        await tester.pumpAndSettle();
        expect(
          find.byType(LoginView),
          findsOne,
          reason: 'Should show LoginView after logout for $userRole',
        );

        logger.i('Logged out successfully as $userRole');
      }
    });
  });
}
