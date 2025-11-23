import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/mocks/mock_users.dart';
import 'package:test_utils/user_test_runner.dart';
import 'package:integration_test/integration_test.dart';

import '../../../../utils/extensions/widget_finder_extensions.dart';
import '../../../../utils/extensions/widget_tester_extensions.dart';

extension on WidgetTester {
  Future<void> renderUserTile({required User currentUser, required User targetUser}) async =>
      await renderWidgetWithBlocStubs(
        testWidget: UserTile(user: targetUser),
        mockCurrentUser: currentUser,
      );
}

/// Entry point for [UserTile] integration tests.
///
/// Covers presentation scenarios for user tile display.
Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  UserTestRunner.forEachUserPair(
    users: allMockUserPairs,
    onUserPairCase: (actor, subject) {
      testWidgets('displays user tile with all required components', (WidgetTester tester) async {
        await tester.renderUserTile(currentUser: actor, targetUser: subject);

        final userTile = find.byType(UserTile);
        expect(userTile, findsOne);

        expect(find.text(subject.role.name), findsOne);
        expect(find.text(subject.email.value), findsOne);

        expect(userTile.findDescendant(UpdateUserEmailIcon), findsOne);
        expect(userTile.findDescendant(UpdateUserPasswordIcon), findsOne);
        expect(userTile.findDescendant(DeleteUserIcon), findsOne);
      });
    },
  );
}
