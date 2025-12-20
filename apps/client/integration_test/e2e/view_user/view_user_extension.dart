part of 'view_user_test.dart';

final log = IntegrationTestDebugLogger(tag: 'ViewUser');
final userAdministrationService = createStubbedUserAdministrationService();

extension ViewUserExtension on WidgetTester {
  /// Views a target user's details as an initiator.
  ///
  /// This method checks if the initiator is authorized to view the target user.
  /// Depending on the authorization, the target user's details are either displayed or access is blocked.
  ///
  /// - [initiator]: The user initiating the view action.
  /// - [target]: The target user whose details are being viewed.
  Future<void> viewUser({required UserTestFixture initiator, required UserTestFixture target}) async {
    final initiatorRole = initiator.user.role.name;
    final targetRole = initiator.user.isSameAs(target.user) ? 'self' : target.user.role.name;

    await userAdministrationService.authorizeViewUser(
      initiator: initiator.user,
      target: target.user,
      onAuthorized: () async {
        log.authorized('$initiatorRole authorized to view $targetRole');
        await _assertViewUserSucceeds(initiator: initiator, target: target);
      },
      onUnauthorized: (_) async {
        log.unauthorized('$initiatorRole unauthorized to view $targetRole');
        await _assertViewUserIsBlocked(initiator: initiator, target: target);
      },
    );
  }

  /// Verifies that viewing a user's tile succeeds.
  ///
  /// Logs in as the initiator, navigates to the user administration view, and ensures
  /// the target user's tile is visible in the user list.
  ///
  /// - [initiator]: The user initiating the view action.
  /// - [target]: The target user whose details are being viewed.
  Future<void> _assertViewUserSucceeds({required UserTestFixture initiator, required UserTestFixture target}) async {
    await _assertViewUser(initiator: initiator, target: target, shouldFind: true);
  }

  /// Verifies that viewing a user's tile is blocked.
  ///
  /// Logs in as the initiator, navigates to the user administration view, and ensures
  /// the target user's tile is not visible in the user list.
  ///
  /// - [initiator]: The user initiating the view action.
  /// - [target]: The target user whose details are being blocked.
  Future<void> _assertViewUserIsBlocked({required UserTestFixture initiator, required UserTestFixture target}) async {
    await _assertViewUser(initiator: initiator, target: target, shouldFind: false);
  }

  Future<void> _assertViewUser({
    required UserTestFixture initiator,
    required UserTestFixture target,
    required bool shouldFind,
  }) async {
    await startApp();
    await login(email: initiator.email, password: initiator.password);

    final userAdministrationView = find.byType(UserAdministrationView);
    expect(userAdministrationView, findsOne, reason: 'Should show UserAdministrationView after login');

    final userList = userAdministrationView.findDescendant(UserList);
    expect(userList, findsOne, reason: 'Should show UserList in UserAdministrationView');

    final targetUserTile = userList.findDescendantMatching(
      find.byWidgetPredicate((widget) => widget is UserTile && widget.user.isSameAs(target.user)),
    );

    final targetUserRole = target.user.role.name;

    expect(
      targetUserTile,
      shouldFind ? findsOne : findsNothing,
      reason: shouldFind
          ? 'UserTile should be found for $targetUserRole target'
          : 'UserTile should not be found for $targetUserRole target',
    );

    await logout();
  }
}
