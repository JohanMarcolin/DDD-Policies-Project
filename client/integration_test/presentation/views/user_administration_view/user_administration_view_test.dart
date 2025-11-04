import 'package:client/presentation/views/user_administration_view/blocs/users_view_bloc/user_administration_view_bloc.dart';
import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:client/presentation/widgets/base_app_bar.dart';
import 'package:domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:mocktail/mocktail.dart';
import '../../../../test/bloc/utils/mock_users.dart';
import '../../../utils/extensions/widget_finder_extension.dart';
import '../../../utils/extensions/widget_tester_extension.dart';

late User currentUser;
late MockUserRepository mockUserRepository;

extension on WidgetTester {
  Future<void> renderUserAdministrationView() async =>
      await renderWidgetWithBlocStubs(
        testWidget: UserAdministrationView(),
        currentUser: currentUser,
        mockUserRepository: mockUserRepository,
      );
}

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('UserAdministrationView', () {
    setUp(() {
      currentUser = mockUser;
      mockUserRepository = MockUserRepository();
    });
    testWidgets(
      'displays user administration view with all required static components',
      (WidgetTester tester) async {
        await tester.renderUserAdministrationView();

        final userAdministrationView = find.byType(UserAdministrationView);
        expect(userAdministrationView, findsOne);

        final userAdministrationAppBar = userAdministrationView.findDescendant(
          BaseAppBar,
        );
        expect(userAdministrationAppBar, findsOne);
        expect(
          userAdministrationAppBar.findDescendantMatching(
            find.text('User Administration'),
          ),
          findsOne,
        );
      },
    );

    testWidgets('shows loading indicator when fetching users', (
      WidgetTester tester,
    ) async {
      when(() => mockUserRepository.users).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 1));
        return [];
      });

      await tester.renderUserAdministrationView();

      final userAdministrationView = find.byType(UserAdministrationView);

      tester.blocWithStubs.add(FetchUsersRequested());
      await tester.pump();
      expect(
        userAdministrationView.findDescendant(CircularProgressIndicator),
        findsOne,
      );
    });

    testWidgets('shows failure message when user fetching fails', (
      WidgetTester tester,
    ) async {
      when(
        () => mockUserRepository.users,
      ).thenThrow(Exception('Failed to fetch users'));

      await tester.renderUserAdministrationView();

      final userAdministrationView = find.byType(UserAdministrationView);

      tester.blocWithStubs.add(FetchUsersRequested());
      await tester.pumpAndSettle();
      expect(
        userAdministrationView.findDescendantMatching(
          find.text('Failure loading users'),
        ),
        findsOne,
      );
    });

    testWidgets('shows user list when users are fetched successfully', (
      WidgetTester tester,
    ) async {
      when(() => mockUserRepository.users).thenAnswer((_) async => allMockUserPairs);

      await tester.renderUserAdministrationView();

      final userAdministrationView = find.byType(UserAdministrationView);

      tester.blocWithStubs.add(FetchUsersRequested());
      await tester.pumpAndSettle();
      expect(
        userAdministrationView.findDescendantMatching(find.byType(UserList)),
        findsOne,
      );
    });

    testWidgets('shows no content when users have not been fetched', (
      WidgetTester tester,
    ) async {
      await tester.renderUserAdministrationView();

      final userAdministrationView = find.byType(UserAdministrationView);

      await tester.pumpAndSettle();
      expect(
        userAdministrationView.findDescendant(CircularProgressIndicator),
        findsNothing,
      );
      expect(userAdministrationView.findDescendant(UserList), findsNothing);
    });
  });
}
