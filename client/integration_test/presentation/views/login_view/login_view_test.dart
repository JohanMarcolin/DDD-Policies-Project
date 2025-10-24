import 'package:client/infrastructure/apis/auth_api.dart';
import 'package:client/infrastructure/auth_bloc/auth_bloc.dart';
import 'package:client/infrastructure/services/auth_token_service.dart';
import 'package:client/presentation/views/login_view/components/login_button.dart';
import 'package:client/presentation/views/login_view/components/login_email_field.dart';
import 'package:client/presentation/views/login_view/components/login_password_field.dart';
import 'package:client/presentation/views/login_view/login_view.dart';
import 'package:client/presentation/widgets/action_snack_bar_helper.dart';
import 'package:client/presentation/widgets/base_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:client/infrastructure/apis/integration_test_api.dart';
import 'package:mocktail/mocktail.dart';

import '../../../extensions/widget_finder_extension.dart';
import '../../../extensions/widget_tester_extension.dart';

class MockAuthApi extends Mock implements AuthApi {}

final AuthTokenService authTokenService = AuthTokenService();
final IntegrationTestApi integrationTestApi = IntegrationTestApi();
late List<TestUserEntry> testUserEntries;

extension on WidgetTester {
  Future<void> renderLoginView({MockAuthApi? mockAuthApi}) async {
    final authApi = mockAuthApi ?? AuthApi(authTokenService: authTokenService);
    final authBloc = AuthBloc(authApi: authApi);
    await renderWidgetWithBloc(widget: LoginView(), bloc: authBloc);
  }
}

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('LoginView', () {
    setUpAll(() async {
      testUserEntries = await integrationTestApi.testUserEntries;
    });
    setUp(() async {
      authTokenService.clearTokens();
    });
    testWidgets('displays login view with all required components', (
      WidgetTester tester,
    ) async {
      await tester.renderLoginView();

      final loginView = find.byType(LoginView);
      expect(loginView, findsOne);

      final loginAppBar = loginView.findDescendant(BaseAppBar);
      expect(loginAppBar, findsOne);
      expect(loginAppBar.findDescendantMatching(find.text('Login')), findsOne);

      expect(loginView.findDescendant(LoginEmailField), findsOne);
      expect(loginView.findDescendant(LoginPasswordField), findsOne);
      expect(loginView.findDescendant(LoginButton), findsOne);
    });

    testWidgets('displays success snackbar on valid login', (
      WidgetTester tester,
    ) async {
      final testEntry = testUserEntries.first;
      final validEmail = testEntry.user.email.value;
      final validPassword = testEntry.password.value;

      await tester.renderLoginView();
      await tester.enterText(find.byType(LoginEmailField), validEmail);
      await tester.enterText(find.byType(LoginPasswordField), validPassword);
      final loginButton = find.byType(LoginButton);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(
        ActionSnackBarHelper.lastMessage,
        equals('Logged in as $validEmail'),
      );
    });

    testWidgets(
      'displays error snackbar when login attempted with empty email',
      (WidgetTester tester) async {
        await tester.renderLoginView();
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
        await tester.renderLoginView();
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
        await tester.renderLoginView();
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

        await tester.renderLoginView();
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

      await tester.renderLoginView(mockAuthApi: mockAuthApi);

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
        await tester.renderLoginView();
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
        expect(find.byType(CircularProgressIndicator), findsOne);
      },
    );
  });
}
