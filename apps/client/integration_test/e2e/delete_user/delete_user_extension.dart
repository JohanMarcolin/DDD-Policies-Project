part of 'delete_user_test.dart';

final userAdministrationService = createStubbedUserAdministrationService();

extension DeleteUserExtension on WidgetTester {
  /// Deletes a target user as an initiator.
  ///
  /// This method first checks if the initiator is authorized to view the target user.
  /// If authorized, it proceeds to check if the initiator can delete the target user.
  /// Depending on the authorization, it either deletes the user or asserts that the deletion is blocked.
  ///
  /// [initiator]: The user initiating the deletion.
  /// [target]: The target user who is being deleted.
  Future<void> deleteUser({required UserTestFixture initiator, required UserTestFixture target}) async {
    final canViewTarget = await userAdministrationService.authorizeViewUser(
      initiator: initiator.user,
      target: target.user,
      onAuthorized: () async {
        await assertUserTileIsVisible(initiator: initiator, target: target);
        return true;
      },
      onUnauthorized: (_) async {
        await assertUserTileIsNotVisible(initiator: initiator, target: target);
        return false;
      },
    );

    /// If the initiator cannot view the target, they cannot delete the target.
    if (!canViewTarget) return;

    await userAdministrationService.authorizeDeleteUser(
      initiator: initiator.user,
      target: target.user,
      onAuthorized: () async => await _assertDeleteUserSucceeds(initiator: initiator, target: target),
      onUnauthorized: (_) async => await _assertDeleteUserIsBlocked(initiator: initiator, target: target),
    );
  }

  /// Verifies that deleting a user succeeds.
  ///
  /// Logs in as the initiator, confirms the target user's tile is visible, and deletes the user.
  /// Ensures the tile is no longer visible after deletion. If the initiator deletes themselves,
  /// verifies that they are logged out and cannot log back in with the deleted account.
  ///
  /// [initiator]: The user initiating the deletion.
  /// [target]: The target user to be deleted.
  Future<void> _assertDeleteUserSucceeds({required UserTestFixture initiator, required UserTestFixture target}) async {
    final targetUserRole = target.user.role.name;

    await startApp();
    await login(email: initiator.user.email, password: initiator.password);

    expect(find.byType(UserAdministrationView), findsOne);

    final targetUserTile = findUserTileByUserId(target.user.userId);
    expect(targetUserTile, findsOne, reason: 'UserTile should be found for target $targetUserRole');

    final deleteUserIcon = find.descendant(of: targetUserTile, matching: find.byType(DeleteUserIcon));
    await tap(deleteUserIcon);
    await pumpAndSettle();

    final deleteUserDialogChild = find.byType(DeleteUserDialogChild);
    expect(deleteUserDialogChild, findsOne, reason: 'DeleteUserDialogChild should be shown');

    final confirmDialog = find.descendant(of: deleteUserDialogChild, matching: find.byType(ConfirmDialog));
    expect(confirmDialog, findsOne);

    final confirmButton = findConfirmButton();
    await tap(confirmButton);
    await pumpAndSettle();

    final isDeletingSelf = initiator.user.isSameAs(target.user);

    if (isDeletingSelf) {
      expect(
        find.byType(LoginView),
        findsOne,
        reason: 'Should navigate to LoginView after deletion of target $targetUserRole',
      );

      await login(email: target.user.email, password: target.password);
      expect(
        find.byType(UserAdministrationView),
        findsNothing,
        reason: 'Should not be able to login with deleted target $targetUserRole',
      );
    } else {
      expect(targetUserTile, findsNothing, reason: 'Target $targetUserRole should no longer be listed after deletion');
    }
  }

  /// Verifies that deleting a user is blocked.
  ///
  /// Logs in as the initiator, confirms the target user's tile is visible, and attempts to delete the user.
  /// Ensures that the delete user dialog is not shown and the user remains listed.
  ///
  /// [initiator]: The user initiating the deletion.
  /// [target]: The target user whose deletion is blocked.
  Future<void> _assertDeleteUserIsBlocked({required UserTestFixture initiator, required UserTestFixture target}) async {
    final targetUserRole = target.user.role.name;

    await startApp();
    await login(email: initiator.email, password: initiator.password);

    final targetUserTile = findUserTileByUserId(target.user.userId);
    expect(targetUserTile, findsOne, reason: 'UserTile should be found for $targetUserRole target');

    final deleteUserIcon = find.descendant(of: targetUserTile, matching: find.byType(DeleteUserIcon));
    await tap(deleteUserIcon);
    await pumpAndSettle();

    final deleteUserDialogChild = find.byType(DeleteUserDialogChild);
    expect(deleteUserDialogChild, findsNothing, reason: 'Delete user dialog should not be shown');

    await logout();
  }
}
