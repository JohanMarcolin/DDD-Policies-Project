import 'package:client/infrastructure/apis/auth_api.dart';
import 'package:client/infrastructure/auth_bloc/auth_bloc.dart';
import 'package:client/presentation/views/login_view/login_view.dart';
import 'package:client/presentation/widgets/action_snack_bar_helper.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:api_error_codes/api_error_codes.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_utils/mocks/mock_user_credentials.dart';
import 'package:test_utils/mocks/mock_users.dart';
import '../../../utils/extensions/widget_finder_extensions.dart';
import '../../../../test_utils/mock_auth_api.dart';

late MockAuthApi _mockAuthApi;

extension on WidgetTester {
  Future<void> renderLoginView() async {
    await pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: AuthBloc(authApi: _mockAuthApi),
        child: MaterialApp(home: LoginView()),
      ),
    );
  }
}

/// Entry point for [LoginView] integration tests.
///
/// Covers presentation scenarios for successful and failed login attempts.
Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    _mockAuthApi = MockAuthApi();
  });

  group('LoginView', () {
    testWidgets('displays login view with all required components', (WidgetTester tester) async {
      await tester.renderLoginView();

      final loginView = find.byType(LoginView);
      expect(loginView, findsOne);

      final loginAppBar = loginView.findDescendant(LoginAppBar);
      expect(loginAppBar, findsOne);
      expect(loginAppBar.findDescendantMatching(find.text('Login')), findsOne);

      final loginForm = loginView.findDescendant(LoginForm);
      expect(loginForm, findsOne);
      expect(loginForm.findDescendant(LoginEmailField), findsOne);
      expect(loginForm.findDescendant(LoginPasswordField), findsOne);
      expect(loginForm.findDescendant(LoginButton), findsOne);
    });

    testWidgets('shows loading indicator and disables login button when tapped', (WidgetTester tester) async {
      when(() => _mockAuthApi.login(email: mockAnyEmail, password: mockAnyPassword)).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 2));
        return mockUser;
      });

      await tester.renderLoginView();

      await tester.enterText(find.byType(LoginEmailField), mockAnyEmail.value);
      await tester.enterText(find.byType(LoginPasswordField), mockAnyPassword.value);
      await tester.tap(find.byType(LoginButton));
      await tester.pump();
      final loginButton = tester.widget<LoginButton>(find.byType(LoginButton));

      verify(() => _mockAuthApi.login(email: mockAnyEmail, password: mockAnyPassword)).called(1);
      expect(loginButton.loading, isTrue);
      expect(find.byType(CircularProgressIndicator), findsOne);
    });

    testWidgets('displays success snackbar on valid login', (WidgetTester tester) async {
      final userTestFixture = mockUser;
      final testEmail = mockUser.email;
      final testPassword = mockValidPassword;

      when(() => _mockAuthApi.login(email: testEmail, password: testPassword)).thenAnswer((_) async => userTestFixture);

      await tester.renderLoginView();
      await tester.enterText(find.byType(LoginEmailField), testEmail.value);
      await tester.enterText(find.byType(LoginPasswordField), testPassword.value);
      final loginButton = find.byType(LoginButton);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      verify(() => _mockAuthApi.login(email: testEmail, password: testPassword)).called(1);
      expect(ActionSnackBarHelper.lastMessage, equals('Logged in as ${testEmail.value}'));
    });

    testWidgets('displays error snackbar when login attempted with empty email', (WidgetTester tester) async {
      when(
        () => _mockAuthApi.login(email: mockEmptyEmail, password: mockAnyPassword),
      ).thenThrow(AuthApiException(LoginMissingEmail().toString()));

      await tester.renderLoginView();
      await tester.enterText(find.byType(LoginEmailField), mockEmptyEmail.value);
      await tester.enterText(find.byType(LoginPasswordField), mockAnyPassword.value);
      await tester.tap(find.byType(LoginButton));
      await tester.pumpAndSettle();

      verify(() => _mockAuthApi.login(email: mockEmptyEmail, password: mockAnyPassword)).called(1);
      expect(ActionSnackBarHelper.lastMessage, equals('Please enter your email'));
    });

    testWidgets('displays error snackbar when login attempted with missing password', (WidgetTester tester) async {
      when(
        () => _mockAuthApi.login(email: mockAnyEmail, password: mockEmptyPassword),
      ).thenThrow(AuthApiException(LoginMissingPassword().toString()));

      await tester.renderLoginView();
      await tester.enterText(find.byType(LoginEmailField), mockAnyEmail.value);
      await tester.enterText(find.byType(LoginPasswordField), mockEmptyPassword.value);
      await tester.tap(find.byType(LoginButton));
      await tester.pumpAndSettle();

      verify(() => _mockAuthApi.login(email: mockAnyEmail, password: mockEmptyPassword)).called(1);
      expect(ActionSnackBarHelper.lastMessage, equals('Please enter your password'));
    });

    testWidgets('displays error snackbar when login attempted with unknown email', (WidgetTester tester) async {
      when(
        () => _mockAuthApi.login(email: mockUnknownEmail, password: mockAnyPassword),
      ).thenThrow(AuthApiException(LoginUserNotFound().toString()));

      await tester.renderLoginView();
      await tester.enterText(find.byType(LoginEmailField), mockUnknownEmail.value);
      await tester.enterText(find.byType(LoginPasswordField), mockAnyPassword.value);
      await tester.tap(find.byType(LoginButton));
      await tester.pumpAndSettle();

      verify(() => _mockAuthApi.login(email: mockUnknownEmail, password: mockAnyPassword)).called(1);
      expect(ActionSnackBarHelper.lastMessage, equals('Email not found'));
    });

    testWidgets('displays error snackbar when login attempted with invalid password', (WidgetTester tester) async {
      when(
        () => _mockAuthApi.login(email: mockAnyEmail, password: mockInvalidPassword),
      ).thenThrow(AuthApiException(LoginInvalidPassword().toString()));

      await tester.renderLoginView();
      await tester.enterText(find.byType(LoginEmailField), mockAnyEmail.value);
      await tester.enterText(find.byType(LoginPasswordField), mockInvalidPassword.value);
      await tester.tap(find.byType(LoginButton));
      await tester.pumpAndSettle();

      verify(() => _mockAuthApi.login(email: mockAnyEmail, password: mockInvalidPassword)).called(1);
      expect(ActionSnackBarHelper.lastMessage, equals('Invalid password'));
    });

    testWidgets('shows authentication failed snackbar for AuthFailure state', (WidgetTester tester) async {
      final mockAnyEmail = Email('mockAnyEmail');
      final mockAnyPassword = Password('mockAnyPassword');

      when(
        () => _mockAuthApi.login(email: mockAnyEmail, password: mockAnyPassword),
      ).thenThrow(Exception('Some unexpected error'));

      await tester.renderLoginView();

      await tester.enterText(find.byType(LoginEmailField), mockAnyEmail.value);
      await tester.enterText(find.byType(LoginPasswordField), mockAnyPassword.value);
      await tester.tap(find.byType(LoginButton));
      await tester.pumpAndSettle();

      verify(() => _mockAuthApi.login(email: mockAnyEmail, password: mockAnyPassword)).called(1);
      expect(ActionSnackBarHelper.lastMessage, equals('Authentication failed. Please try again'));
    });
  });
}
