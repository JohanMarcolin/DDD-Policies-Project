import 'package:client/infrastructure/apis/http_api.dart';
import 'package:client/infrastructure/apis/test_api.dart';
import 'package:client/infrastructure/services/auth_token_service.dart';
import 'package:client/presentation/views/login_view/login_view.dart';
import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:client/presentation/widgets/confirm_input_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:client/main.dart' as app;
import 'package:server/test/utils/factories/test_server_factory.dart';

late TestApi testApi;
late AuthTokenService authTokenService;
late TestUserEntry testUserEntry;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await TestServerFactory.start();
    HttpApi.baseUrl = TestServerFactory.baseUrl;
    testApi = TestApi();
    authTokenService = AuthTokenService();
  });

  setUp(() async {
    await authTokenService.clearTokens();
    testUserEntry = await testApi.getTestUserEntry();
  });

  tearDown(() async {
    await testApi.deleteTestUserEntry(userId: testUserEntry.userId);
    await authTokenService.clearTokens();
  });

  tearDownAll(() async {
    await TestServerFactory.stop();
  });

  group('User Lifecycle E2E', () {
    testWidgets('full user lifecycle: login, view, logout', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.byType(LoginView), findsOne);

      await tester.enterText(
        find.byType(LoginEmailField),
        testUserEntry.email.value,
      );
      await tester.enterText(
        find.byType(LoginPasswordField),
        testUserEntry.password.value,
      );
      await tester.tap(find.byType(LoginButton));
      await tester.pumpAndSettle();

      expect(find.byType(UserAdministrationView), findsOne);
      expect(find.byType(UserList), findsOne);

      final userTile = find.byWidgetPredicate(
        (widget) =>
            widget is UserTile &&
            widget.user.email.value == testUserEntry.email.value,
      );
      expect(userTile, findsOne);

      final updateEmailIcon = find.descendant(
        of: userTile,
        matching: find.byType(UpdateUserEmailIcon),
      );

      await tester.tap(updateEmailIcon);
      await tester.pumpAndSettle();

      final emailUpdateDialogChild = find.byType(UpdateUserEmailDialogChild);
      expect(emailUpdateDialogChild, findsOne);

      final confirmInputDialog = find.descendant(
        of: emailUpdateDialogChild,
        matching: find.byType(ConfirmInputDialog),
      );

      expect(confirmInputDialog, findsOne);

      final emailField = find.descendant(
        of: confirmInputDialog,
        matching: find.byType(TextField),
      );

      await tester.enterText(emailField, 'new_email@example.com');

      final confirmButton = find.byWidgetPredicate(
        (widget) =>
            widget is TextButton &&
            widget.child is Text &&
            (widget.child as Text).data == 'Confirm',
      );

      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      expect(userTile, findsNothing);

      final updatedUserTile = find.byWidgetPredicate(
        (widget) =>
            widget is UserTile &&
            widget.user.email.value == 'new_email@example.com',
      );
      expect(updatedUserTile, findsOne);

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      expect(find.byType(LoginView), findsOne);
    });
  });
}
