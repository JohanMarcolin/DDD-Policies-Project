import 'package:client/infrastructure/auth_bloc/auth_bloc.dart';
import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:client/presentation/widgets/action_snack_bar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../test/bloc/infrastructure/auth_bloc_test.dart';
import '../../../../../test/bloc/presentation/user_administration_view/mock_user_administration_view_bloc_factory.dart';
import '../../../../../test/bloc/utils/mock_users.dart';
import '../../../../utils/extensions/widget_finder_extensions.dart';
import '../../../../utils/extensions/widget_tester_extensions.dart';

late MockAuthApi mockAuthApi;
late MockUserRepository mockUserRepository;

extension on WidgetTester {
  Future<void> renderUserAdministrationAppBar() async => await renderWidgetWithBlocStubs(
    testWidget: UserAdministrationAppBar(),
    mockAuthApi: mockAuthApi,
    mockUserRepository: mockUserRepository,
  );
}

/// Entry point for [UserAdministrationAppBar] integration tests.
///
/// Covers presentation scenarios for authentication state changes and logout functionality.
Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('UserAdministrationApp', () {
    setUp(() {
      mockAuthApi = MockAuthApi();
      mockUserRepository = MockUserRepository();
    });
    testWidgets('displays app bar with all required static components', (WidgetTester tester) async {
      await tester.renderUserAdministrationAppBar();

      final userAdministrationAppBar = find.byType(UserAdministrationAppBar);
      expect(userAdministrationAppBar, findsOne);
      expect(userAdministrationAppBar.findDescendantMatching(find.text('User Administration')), findsOne);
    });

    testWidgets('does not show logout icon when unauthenticated', (WidgetTester tester) async {
      await tester.renderUserAdministrationAppBar();

      tester.authBlocWithStubs.add(AuthRefreshRequested());

      await tester.pumpAndSettle();

      final logoutIcon = find.byIcon(Icons.logout);
      expect(logoutIcon, findsNothing);
    });

    testWidgets('shows logout icon when authenticated and triggers logout event', (WidgetTester tester) async {
      when(() => mockAuthApi.refreshAccessToken()).thenAnswer((_) async => mockUser);

      when(() => mockAuthApi.logout()).thenAnswer((_) async {});

      await tester.renderUserAdministrationAppBar();

      tester.authBlocWithStubs.add(AuthRefreshRequested());

      await tester.pumpAndSettle();

      final logoutIcon = find.byIcon(Icons.logout);
      expect(logoutIcon, findsOne);
      await tester.tap(logoutIcon);

      verify(() => mockAuthApi.logout()).called(1);
    });

    testWidgets('shows auth failure message when logout fails', (WidgetTester tester) async {
      when(() => mockAuthApi.refreshAccessToken()).thenAnswer((_) async => mockUser);

      when(() => mockAuthApi.logout()).thenAnswer((_) async {
        throw Exception('Logout failed');
      });

      await tester.renderUserAdministrationAppBar();

      tester.authBlocWithStubs.add(AuthRefreshRequested());

      await tester.pumpAndSettle();

      final logoutIcon = find.byIcon(Icons.logout);
      expect(logoutIcon, findsOne);
      await tester.tap(logoutIcon);

      verify(() => mockAuthApi.logout()).called(1);

      expect(ActionSnackBarHelper.lastMessage, 'Logout failed. Please log in again or try again later.');
    });
  });
}
