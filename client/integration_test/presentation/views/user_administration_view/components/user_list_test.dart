import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../../../../../test/bloc/utils/mock_users.dart';
import '../../../../utils/extensions/widget_finder_extension.dart';
import '../../../../utils/extensions/widget_tester_extension.dart';

late List<User> users;

extension on WidgetTester {
  Future<void> renderUserList(List<User> users) async =>
      await renderWidgetWithBlocStubs(testWidget: UserList(users: users));
}

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    users = allMockUserPairs;
  });

  group('userList', () {
    testWidgets('displays user list with all provided users', (
      WidgetTester tester,
    ) async {
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
