import 'package:client/infrastructure/apis/http_api.dart';
import 'package:client/infrastructure/apis/test_api.dart';
import 'package:client/infrastructure/services/auth_token_service.dart';
import 'package:client/presentation/views/login_view/login_view.dart';
import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:client/presentation/widgets/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:client/main.dart' as app;
import 'package:server/test/utils/factories/test_server_factory.dart';

import '../utils/extensions/widget_tester_extension.dart';

late TestApi testApi;
late AuthTokenService authTokenService;
late List<UserEntry> testUserEntries;
late UserEntry userEntry;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Delete User', () {
    setUpAll(() async {
      await TestServerFactory.start(enableTestRoutes: true);
      HttpApi.baseUrl = TestServerFactory.baseUrl;
      testApi = TestApi();
      authTokenService = AuthTokenService();
    });

    setUp(() async {
      testUserEntries = await testApi.createAllUserPairs();
      userEntry = testUserEntries.first;
    });

    tearDown(() async {
      await testApi.deleteAllTestUsers();
      await authTokenService.clearTokens();
    });

    tearDownAll(() async {
      await TestServerFactory.stop();
      await authTokenService.clearTokens();
    });

    testWidgets('should delete user successfully', (WidgetTester tester) async {
      app.main();
      await tester.startApp();

      await tester.login(
        email: userEntry.user.email,
        password: userEntry.password,
      );

      expect(find.byType(UserAdministrationView), findsOne);

      final userTile = tester.findUserTileByEmail(userEntry.user.email);
      expect(
        userTile,
        findsOne,
        reason: 'UserTile should be found for logged in user',
      );

      final deleteUserIcon = find.descendant(
        of: userTile,
        matching: find.byType(DeleteUserIcon),
      );

      await tester.tap(deleteUserIcon);
      await tester.pumpAndSettle();

      final deleteUserDialogChild = find.byType(DeleteUserDialogChild);
      expect(
        deleteUserDialogChild,
        findsOne,
        reason: 'DeleteUserDialogChild should be shown',
      );

      final confirmDialog = find.descendant(
        of: deleteUserDialogChild,
        matching: find.byType(ConfirmDialog),
      );

      expect(confirmDialog, findsOne);

      final confirmButton = tester.findConfirmButton();

      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      expect(
        find.byType(LoginView),
        findsOne,
        reason: 'Should navigate to LoginView after user deletion',
      );

      await tester.login(
        email: userEntry.user.email,
        password: userEntry.password,
      );

      expect(
        find.byType(UserAdministrationView),
        findsNothing,
        reason: 'Should not login with deleted user',
      );
    });
  });
}
