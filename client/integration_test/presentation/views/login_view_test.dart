import 'package:client/infrastructure/apis/auth_api.dart';
import 'package:client/infrastructure/services/auth_token_service.dart';
import 'package:client/presentation/views/login_view/components/login_button.dart';
import 'package:client/presentation/views/login_view/login_view_keys.dart';
import 'package:client/presentation/widgets/action_snack_bar_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:client/main.dart' as app;

import '../../../lib/infrastructure/apis/integration_test_api.dart';

final AuthTokenService authTokenService = AuthTokenService();
final IntegrationTestApi integrationTestApi = IntegrationTestApi();
late List<TestUserEntry> testUserEntries;

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('LoginView', () {
    setUpAll(() async {
      testUserEntries = await integrationTestApi.testUserEntries;
    });
    setUp(() async {
      authTokenService.clearTokens();
    });
    testWidgets('renders all fields and button', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      expect(find.byKey(LoginViewKeys.appBar), findsOneWidget);
      expect(find.byKey(LoginViewKeys.emailField), findsOneWidget);
      expect(find.byKey(LoginViewKeys.passwordField), findsOneWidget);
      expect(find.byType(LoginButton), findsOneWidget);
      expect(
        ActionSnackBarHelper.lastMessage,
        equals('Missing refresh token. Please log in again.'),
      );
    });

    testWidgets('shows success message on login', (WidgetTester tester) async {
      final testEntry = testUserEntries.first;
      final validEmail = testEntry.user.email.value;
      final validPassword = testEntry.password.value;

      app.main();
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(LoginViewKeys.emailField), validEmail);
      await tester.enterText(
        find.byKey(LoginViewKeys.passwordField),
        validPassword,
      );
      await tester.tap(find.byKey(LoginViewKeys.loginButton));
      await tester.pumpAndSettle();
      expect(
        ActionSnackBarHelper.lastMessage,
        equals('Logged in as $validEmail'),
      );
    });

    testWidgets('shows error on empty login', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(LoginViewKeys.emailField), '');
      await tester.tap(find.byKey(LoginViewKeys.loginButton));
      await tester.pumpAndSettle();
      expect(
        ActionSnackBarHelper.lastMessage,
        equals('Please enter your email.'),
      );
    });

    testWidgets('shows error for missing password', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(LoginViewKeys.emailField),
        'user@example.com',
      );
      await tester.tap(find.byKey(LoginViewKeys.loginButton));
      await tester.pumpAndSettle();
      expect(
        ActionSnackBarHelper.lastMessage,
        equals('Please enter your password.'),
      );
    });

    testWidgets('shows error for user not found', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(LoginViewKeys.emailField),
        'notfound@example.com',
      );
      await tester.enterText(
        find.byKey(LoginViewKeys.passwordField),
        'password123',
      );
      await tester.tap(find.byKey(LoginViewKeys.loginButton));
      await tester.pumpAndSettle();
      expect(ActionSnackBarHelper.lastMessage, equals('Email not found.'));
    });

    testWidgets('shows error for invalid password', (
      WidgetTester tester,
    ) async {
      final testEntry = testUserEntries.first;
      final validEmail = testEntry.user.email.value;
      app.main();
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(LoginViewKeys.emailField), validEmail);
      await tester.enterText(
        find.byKey(LoginViewKeys.passwordField),
        'invalidpassword',
      );
      await tester.tap(find.byKey(LoginViewKeys.loginButton));
      await tester.pumpAndSettle();
      expect(ActionSnackBarHelper.lastMessage, equals('Invalid password.'));
    });
  });
}
