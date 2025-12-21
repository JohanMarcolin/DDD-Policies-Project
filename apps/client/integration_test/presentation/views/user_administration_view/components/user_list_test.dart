import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:test_utils/mocks/mock_users.dart';

import '../../../../utils/extensions/widget_finder_extensions.dart';
import '../../../../utils/extensions/widget_tester_extensions.dart';

late List<User> _users;

extension on WidgetTester {
  Future<void> renderUserList(List<User> users) async =>
      await renderWidgetWithBlocStubs(testWidget: UserList(users: users));
}

/// Entry point for [UserList] integration tests.
///
  /// Covers presentation scenarios for user list display.
  Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    _users = [mockUser, mockAdmin, mockAnalyst];
  });

  group('userList', () {
    testWidgets('displays user list with all provided users', (WidgetTester tester) async {
      await tester.renderUserList(_users);

      final userList = find.byType(UserList);
      expect(userList, findsOne);

      expect(userList.findDescendant(UserTile), findsExactly(_users.length));

      for (final user in _users) {
        final userTileFinder = find.descendant(
          of: userList,
          matching: find.byWidgetPredicate((widget) {
            return widget is UserTile && widget.user.userId == user.userId;
          }),
        );
        expect(userTileFinder, findsOne);
      }
    });
  });
}
