import 'package:client/presentation/views/user_administration_view/user_administration_view.dart';
import 'package:client/presentation/widgets/action_icon.dart';
import 'package:client/presentation/widgets/action_snack_bar_helper.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_authorization_policies/user_administration/user_administration_policy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_utils/domain/user_administration_service.dart';
import 'package:test_utils/mocks/mock_user_repository.dart';
import 'package:test_utils/mocks/mock_users.dart';
import 'package:test_utils/user_pair_test_util.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../../../../utils/extensions/widget_finder_extensions.dart';
import '../../../../../utils/extensions/widget_tester_extensions.dart';

late MockUserRepository mockUserRepository;

extension on WidgetTester {
  Future<void> renderDeleteUserIcon({required User initiator, required User target}) async {
    return renderWidgetWithBlocStubs(
      testWidget: DeleteUserIcon(user: target),
      mockCurrentUser: initiator,
      mockUserRepository: mockUserRepository,
    );
  }
}

/// Entry point for [DeleteUserIcon] integration tests.
///
/// Covers presentation scenarios for successful and failed delete user attempts.
Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final userAdministrationService = createStubbedUserAdministrationService();

  setUp(() {
    mockUserRepository = MockUserRepository();
  });

  UserPairTestUtil.forEachUserPair(
    users: allMockUserPairs,
    onUserPair: (initiator, target) {
      userAdministrationService.authorizeDeleteUser(
        initiator: initiator,
        target: target,
        onAuthorized: () {
          testWidgets('shows solid action icon', (WidgetTester tester) async {
            await tester.renderDeleteUserIcon(initiator: initiator, target: target);

            final deleteUserIcon = find.byType(DeleteUserIcon);
            expect(deleteUserIcon, findsOne);

            final actionIcon = deleteUserIcon.findDescendant(ActionIcon);
            expect(actionIcon, findsOne);
            final actionIconWidget = tester.widget<ActionIcon>(actionIcon);

            expect(actionIconWidget.isGreyedOut, isFalse);
          });

          testWidgets('shows dialog when action icon is tapped', (WidgetTester tester) async {
            await tester.renderDeleteUserIcon(initiator: initiator, target: target);

            final deleteUserIcon = find.byType(DeleteUserIcon);
            final actionIcon = deleteUserIcon.findDescendant(ActionIcon);
            expect(actionIcon, findsOne);

            await tester.tap(actionIcon);
            await tester.pumpAndSettle();

            final deleteUserDialogChild = find.byType(DeleteUserDialogChild);
            expect(deleteUserDialogChild, findsOne);

            final isUserDeletingSelf = initiator.isSameAs(target);

            final expectedTitle = isUserDeletingSelf ? 'Delete your account' : 'Delete user account';
            expect(find.text(expectedTitle), findsOne);

            final expectedLabel = isUserDeletingSelf
                ? 'Are you sure you want to delete your own account?'
                : 'Are you sure you want to delete this user?';
            expect(find.text(expectedLabel), findsOne);
          });

          testWidgets('cancel closes dialog', (WidgetTester tester) async {
            await tester.renderDeleteUserIcon(initiator: initiator, target: target);
            final actionIcon = find.byType(ActionIcon);
            await tester.tap(actionIcon);
            await tester.pumpAndSettle();
            expect(find.byType(DeleteUserDialogChild), findsOne);
            final cancelButton = find.text('Cancel');
            await tester.tap(cancelButton);
            await tester.pumpAndSettle();
            expect(find.byType(DeleteUserDialogChild), findsNothing);
          });

          testWidgets('confirm with valid delete shows success snackbar and closes dialog', (
            WidgetTester tester,
          ) async {
            when(() => mockUserRepository.delete(userId: target.userId)).thenAnswer((_) async => {});

            await tester.renderDeleteUserIcon(initiator: initiator, target: target);
            final actionIcon = find.byType(ActionIcon);
            await tester.tap(actionIcon);
            await tester.pumpAndSettle();
            expect(find.byType(DeleteUserDialogChild), findsOne);

            final confirmButton = find.text('Confirm');
            await tester.tap(confirmButton);
            await tester.pumpAndSettle();

            expect(find.byType(DeleteUserDialogChild), findsNothing);

            verify(() => mockUserRepository.delete(userId: target.userId)).called(1);

            final expectedMessage = initiator.isSameAs(target)
                ? 'You have deleted your account'
                : 'User deleted successfully';
            expect(ActionSnackBarHelper.lastMessage, expectedMessage);
          });
        },
        onUnauthorized: (reason) {
          testWidgets('should show greyed out action icon', (WidgetTester tester) async {
            await tester.renderDeleteUserIcon(initiator: initiator, target: target);

            final deleteUserIcon = find.byType(DeleteUserIcon);
            expect(deleteUserIcon, findsOne);

            final actionIcon = deleteUserIcon.findDescendant(ActionIcon);
            expect(actionIcon, findsOne);
            final actionIconWidget = tester.widget<ActionIcon>(actionIcon);

            expect(actionIconWidget.isGreyedOut, isTrue);
          });

          testWidgets('shows snackbar when action icon is tapped', (WidgetTester tester) async {
            await tester.renderDeleteUserIcon(initiator: initiator, target: target);

            final deleteUserIcon = find.byType(DeleteUserIcon);
            final actionIcon = deleteUserIcon.findDescendant(ActionIcon);
            expect(actionIcon, findsOne);

            await tester.tap(actionIcon);
            await tester.pumpAndSettle();
            final deleteUserDialogChild = find.byType(DeleteUserDialogChild);

            expect(deleteUserDialogChild, findsNothing);
            switch (reason) {
              case CannotDeleteSelf():
                expect(ActionSnackBarHelper.lastMessage, 'You cannot delete yourself');
              case CannotDeleteAnalyst():
                expect(ActionSnackBarHelper.lastMessage, 'You cannot delete an analyst');
              case CanOnlyDeleteSelf():
                expect(ActionSnackBarHelper.lastMessage, 'You can only delete your own account');
            }
          });
        },
      );
    },
  );
}
