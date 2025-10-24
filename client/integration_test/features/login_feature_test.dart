import 'package:client/infrastructure/apis/auth_api.dart';
import 'package:client/infrastructure/auth_bloc/auth_bloc.dart';
import 'package:client/infrastructure/services/auth_token_service.dart';
import 'package:client/presentation/views/login_view/components/login_button.dart';
import 'package:client/presentation/views/login_view/components/login_email_field.dart';
import 'package:client/presentation/views/login_view/components/login_password_field.dart';
import 'package:client/presentation/views/login_view/login_view.dart';
import 'package:client/presentation/widgets/action_snack_bar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:client/main.dart' as app;

import 'package:client/infrastructure/apis/integration_test_api.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthApi extends Mock implements AuthApi {}

final AuthTokenService authTokenService = AuthTokenService();
final IntegrationTestApi integrationTestApi = IntegrationTestApi();
late List<TestUserEntry> testUserEntries;

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Feature', () {
    setUpAll(() async {
      testUserEntries = await integrationTestApi.testUserEntries;
    });
    setUp(() async {
      authTokenService.clearTokens();
    });
    testWidgets(
      'displays login form with email and password fields, and login button',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();
        expect(find.byType(LoginEmailField), findsOneWidget);
        expect(find.byType(LoginPasswordField), findsOneWidget);
        expect(find.byType(LoginButton), findsOneWidget);
        expect(
          ActionSnackBarHelper.lastMessage,
          equals('Missing refresh token. Please log in again.'),
        );
      },
    );

    testWidgets('displays success snackbar and sets tokens on valid login', (
      WidgetTester tester,
    ) async {
      final testEntry = testUserEntries.first;
      final validEmail = testEntry.user.email.value;
      final validPassword = testEntry.password.value;

      app.main();
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(LoginEmailField), validEmail);
      await tester.enterText(find.byType(LoginPasswordField), validPassword);
      final loginButton = find.byType(LoginButton);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(await authTokenService.hasAccessToken, isTrue);
      expect(await authTokenService.hasRefreshToken, isTrue);
      expect(
        ActionSnackBarHelper.lastMessage,
        equals('Logged in as $validEmail'),
      );
    });

    testWidgets(
      'displays error snackbar when login attempted with empty email',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(LoginEmailField), '');
        await tester.tap(find.byType(LoginButton));
        await tester.pumpAndSettle();
        expect(
          ActionSnackBarHelper.lastMessage,
          equals('Please enter your email.'),
        );
      },
    );

    testWidgets(
      'displays error snackbar when login attempted with missing password',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byType(LoginEmailField),
          'user@example.com',
        );
        await tester.tap(find.byType(LoginButton));
        await tester.pumpAndSettle();
        expect(
          ActionSnackBarHelper.lastMessage,
          equals('Please enter your password.'),
        );
      },
    );

    testWidgets(
      'displays error snackbar when login attempted with unknown email',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byType(LoginEmailField),
          'notfound@example.com',
        );
        await tester.enterText(find.byType(LoginPasswordField), 'password123');
        await tester.tap(find.byType(LoginButton));
        await tester.pumpAndSettle();
        expect(ActionSnackBarHelper.lastMessage, equals('Email not found.'));
      },
    );

    testWidgets(
      'displays error snackbar when login attempted with invalid password',
      (WidgetTester tester) async {
        final testEntry = testUserEntries.first;
        final validEmail = testEntry.user.email.value;
        app.main();
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(LoginEmailField), validEmail);
        await tester.enterText(
          find.byType(LoginPasswordField),
          'invalidpassword',
        );
        await tester.tap(find.byType(LoginButton));
        await tester.pumpAndSettle();
        expect(ActionSnackBarHelper.lastMessage, equals('Invalid password.'));
      },
    );

    testWidgets('shows authentication failed snackbar for AuthFailure state', (
      WidgetTester tester,
    ) async {
      final testEntry = testUserEntries.first;
      final validEmail = testEntry.user.email;
      final validPassword = testEntry.password;

      final mockAuthApi = MockAuthApi();
      when(
        () => mockAuthApi.login(email: validEmail, password: validPassword),
      ).thenThrow(Exception('Unexpected error'));

      await tester.pumpWidget(
        BlocProvider<AuthBloc>.value(
          value: AuthBloc(authApi: mockAuthApi),
          child: MaterialApp(home: LoginView()),
        ),
      );

      await tester.pumpAndSettle();
      await tester.enterText(find.byType(LoginEmailField), validEmail.value);
      await tester.enterText(
        find.byType(LoginPasswordField),
        validPassword.value,
      );
      await tester.tap(find.byType(LoginButton));
      await tester.pumpAndSettle();
      expect(
        ActionSnackBarHelper.lastMessage,
        equals('Authentication failure. Please try again.'),
      );
    });

    testWidgets(
      'shows loading indicator and disables login button when tapped',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byType(LoginEmailField),
          'user@example.com',
        );
        await tester.enterText(find.byType(LoginPasswordField), 'password123');
        await tester.tap(find.byType(LoginButton));
        await tester.pump();
        final loginButton = tester.widget<LoginButton>(
          find.byType(LoginButton),
        );
        expect(loginButton.loading, isTrue);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );
  });
}
