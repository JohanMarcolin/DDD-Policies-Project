import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../../../../../test/bloc/utils/mock_users.dart';
import '../../../../utils/extensions/widget_finder_extensions.dart';
import '../../../../utils/extensions/widget_tester_extensions.dart';

late List<User> users;

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
    users = [mockUser, mockAdmin, mockAnalyst];
  });

  group('userList', () {
    testWidgets('displays user list with all provided users', (WidgetTester tester) async {
      await tester.renderUserList(users);

      final userList = find.byType(UserList);
      expect(userList, findsOne);

      expect(userList.findDescendant(UserTile), findsExactly(users.length));

      for (final user in users) {
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
