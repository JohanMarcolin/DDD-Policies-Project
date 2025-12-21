import 'package:client/infrastructure/auth_bloc/auth_bloc.dart';
import 'package:client/main.dart';
import 'package:client/presentation/views/login_view/login_view.dart';
import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_utils/mocks/mock_users.dart';

import '../utils/extensions/widget_finder_extensions.dart';
import '../utils/extensions/widget_tester_extensions.dart';
import '../../test_utils/mock_auth_api.dart';

late MockAuthApi _mockAuthApi;

extension on WidgetTester {
  Future<void> renderUserAdministrationApp() async =>
      await renderWidgetWithBlocStubs(testWidget: UserAdministrationApp(), mockAuthApi: _mockAuthApi);
}

/// Entry point for [UserAdministrationApp] integration tests.
///
/// Covers presentation scenarios for user administration app display.
Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('UserAdministrationApp', () {
    setUp(() {
      _mockAuthApi = MockAuthApi();
    });
    testWidgets('displays user administration view with all required static components', (WidgetTester tester) async {
      await tester.renderUserAdministrationApp();

      final userAdministrationApp = find.byType(UserAdministrationApp);
      expect(userAdministrationApp, findsOne);
    });

    testWidgets('shows login view when user is not authenticated', (WidgetTester tester) async {
      await tester.renderUserAdministrationApp();

      final userAdministrationApp = find.byType(UserAdministrationApp);
      expect(userAdministrationApp, findsOne);

      await tester.pumpAndSettle();

      final loginView = userAdministrationApp.findDescendant(LoginView);
      expect(loginView, findsOne);
    });

    testWidgets('shows user administration view when user is authenticated', (WidgetTester tester) async {
      when(() => _mockAuthApi.refreshAccessToken()).thenAnswer((_) async => mockUser);

      await tester.renderUserAdministrationApp();

      final userAdministrationApp = find.byType(UserAdministrationApp);
      expect(userAdministrationApp, findsOne);

      tester.authBlocWithStubs.add(AuthRefreshAccessTokenRequested());

      await tester.pump();

      final userAdministrationView = userAdministrationApp.findDescendant(UserAdministrationView);
      expect(userAdministrationView, findsOne);
    });
  });
}
