import 'package:client/infrastructure/apis/http_api.dart';
import 'package:client/infrastructure/apis/test_api.dart';
import 'package:client/infrastructure/services/auth_token_service.dart';
import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:client/presentation/widgets/confirm_input_dialog.dart';
import 'package:domain/value_objects/email.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:logger/logger.dart';
import 'package:server/test/utils/factories/test_server_factory.dart';

import '../utils/extensions/widget_tester_extension.dart';

final logger = Logger();

late TestApi testApi;
late AuthTokenService authTokenService;
late List<UserEntry> userEntries;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Update User Email Lifecycle', () {
    setUpAll(() async {
      await TestServerFactory.start(enableTestRoutes: true);
      HttpApi.baseUrl = TestServerFactory.baseUrl;
      testApi = TestApi();
      authTokenService = AuthTokenService();
      userEntries = await testApi.createAllUserPairs();
    });

    tearDown(() async {
      await authTokenService.clearTokens();
    });

    tearDownAll(() async {
      await testApi.deleteAllTestUsers();
      await TestServerFactory.stop();
    });

    testWidgets('should update email successfully with valid email', (
      WidgetTester tester,
    ) async {
      for (final entry in userEntries) {
        final userRole = entry.user.role.name;
        final email = entry.user.email;
        final password = entry.password;

        logger.i('Logging in as $userRole');

        await tester.startApp();

        await tester.login(email: email, password: password);

        final userTile = tester.findUserTileByEmail(email);
        expect(
          userTile,
          findsOne,
          reason: 'UserTile should be found for logged in user',
        );

        final updateEmailIcon = find.descendant(
          of: userTile,
          matching: find.byType(UpdateUserEmailIcon),
        );

        await tester.tap(updateEmailIcon);
        await tester.pumpAndSettle();

        final emailUpdateDialogChild = find.byType(UpdateUserEmailDialogChild);
        expect(
          emailUpdateDialogChild,
          findsOne,
          reason: 'Email update dialog should be shown',
        );

        final confirmInputDialog = find.descendant(
          of: emailUpdateDialogChild,
          matching: find.byType(ConfirmInputDialog),
        );

        expect(
          confirmInputDialog,
          findsOne,
          reason: 'Confirm input dialog should be shown',
        );

        final emailField = find.descendant(
          of: confirmInputDialog,
          matching: find.byType(TextField),
        );

        final newEmail = Email('new_${userRole}_email@example.com');

        await tester.enterText(emailField, newEmail.value);

        final confirmButton = tester.findConfirmButton();

        logger.i('Confirming email update for $userRole');

        await tester.tap(confirmButton);
        await tester.pumpAndSettle();

        final oldUserTile = userTile;

        expect(
          oldUserTile,
          findsNothing,
          reason: 'Old UserTile should no longer be found after email update',
        );

        final updatedUserTile = tester.findUserTileByEmail(newEmail);
        expect(
          updatedUserTile,
          findsOne,
          reason: 'UserTile should be found with new email',
        );

        logger.i('Email update successful for $userRole');

        await tester.logout();
      }
    });
  });
}
