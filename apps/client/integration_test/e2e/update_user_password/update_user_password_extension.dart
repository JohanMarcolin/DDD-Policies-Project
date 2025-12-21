part of 'update_user_password_test.dart';

final _log = IntegrationTestDebugLogger(tag: 'UpdateUserPassword');
final _authorizationService = createStubbedUserAdministrationService();

extension UpdateUserPasswordExtension on WidgetTester {
  /// Updates the password of a target user as an initiator.
  ///
  /// Checks if the initiator is authorized to view the target user.
  /// If authorized, it verifies if the initiator can update the target's password.
  /// Depending on the authorization, the password is either updated or the update is blocked.
  ///
  /// [initiator]: The user initiating the password update.
  /// [target]: The target user whose password is being updated.
  Future<void> updateUserPassword({required UserTestFixture initiator, required UserTestFixture target}) async {
    final initiatorRole = initiator.user.role.name;
    final targetRole = initiator.user.isSameAs(target.user) ? 'self' : target.user.role.name;

    final canViewTarget = await _authorizationService.authorizeViewUser(
      initiator: initiator.user,
      target: target.user,
      onAuthorized: () async {
        _log.authorized('$initiatorRole authorized to view $targetRole');
        await verifyUserTileIsVisible(initiator: initiator, target: target);
        return true;
      },
      onUnauthorized: (_) async {
        _log.unauthorized('$initiatorRole unauthorized to view $targetRole');
        await verifyUserTileIsNotVisible(initiator: initiator, target: target);
        return false;
      },
    );

    /// If the initiator cannot view the target, they cannot update the target's password.
    if (!canViewTarget) return;

    await _authorizationService.authorizeUpdateUserPassword(
      initiator: initiator.user,
      target: target.user,
      onAuthorized: () async {
        _log.authorized('$initiatorRole authorized to update password for $targetRole');
        await _verifyUpdatePasswordSucceeds(
          initiator: initiator,
          target: target,
          newPassword: _authorizationService.generateUserPassword(),
        );
      },
      onUnauthorized: (_) async {
        _log.unauthorized('$initiatorRole unauthorized to update password for $targetRole');
        await _verifyUpdatePasswordIsBlocked(initiator: initiator, target: target);
      },
    );
  }

  /// Verifies that updating a user's password succeeds.
  ///
  /// Logs in as the initiator and verifies the target user's tile is visible.
  /// Updates the password and ensures the dialog closes after the update.
  /// Verifies that the old password cannot be used to log in and that the new password works.
  ///
  /// [initiator]: The user initiating the password update.
  /// [target]: The target user whose password is being updated.
  /// [newPassword]: The new password to set for the target user.
  Future<void> _verifyUpdatePasswordSucceeds({
    required UserTestFixture initiator,
    required UserTestFixture target,
    required Password newPassword,
  }) async {
    var targetUserRole = target.user.role.name;

    await startApp();

    await login(email: initiator.user.email, password: initiator.password);

    final targetUserTile = findUserTileByUserId(target.user.userId);
    expect(targetUserTile, findsOne, reason: 'UserTile should be found for $targetUserRole target');

    final updatePasswordIcon = find.descendant(of: targetUserTile, matching: find.byType(UpdateUserPasswordIcon));

    await tap(updatePasswordIcon);
    await pumpAndSettle();

    final passwordUpdateDialogChild = find.byType(UpdateUserPasswordDialogChild);
    expect(passwordUpdateDialogChild, findsOne, reason: 'Password update dialog should be shown');

    final confirmInputDialog = find.descendant(
      of: passwordUpdateDialogChild,
      matching: find.byType(ConfirmInputDialog),
    );

    expect(confirmInputDialog, findsOne, reason: 'Confirm input dialog should be shown');

    final passwordField = find.descendant(of: confirmInputDialog, matching: find.byType(TextField));

    await enterText(passwordField, newPassword.value);

    final confirmButton = findConfirmButton();

    await tap(confirmButton);
    await pumpAndSettle();

    expect(confirmInputDialog, findsNothing, reason: 'Dialog should close after password update');

    await logout();

    expect(find.byType(LoginView), findsOne, reason: 'Should show LoginView after logout');

    await login(email: target.user.email, password: target.password);

    expect(
      find.byType(UserAdministrationView),
      findsNothing,
      reason: 'Login should fail with old password for $targetUserRole target',
    );

    await login(email: target.user.email, password: newPassword);

    expect(find.byType(UserAdministrationView), findsOne, reason: 'Login should succeed with new password');
  }

  /// Verifies that updating a user's password is blocked.
  ///
  /// Verifies that the password update dialog is not shown when the initiator
  /// is unauthorized to update the target's password.

  /// [initiator]: The user initiating the password update.
  /// [target]: The target user whose password update is being blocked.
  Future<void> _verifyUpdatePasswordIsBlocked({
    required UserTestFixture initiator,
    required UserTestFixture target,
  }) async {
    await startApp();

    await login(email: initiator.email, password: initiator.password);

    final targetUserTile = findUserTileByUserId(target.user.userId);
    expect(targetUserTile, findsOne, reason: 'UserTile should be found for ${target.user.role.name} target');

    final updatePasswordIcon = find.descendant(of: targetUserTile, matching: find.byType(UpdateUserPasswordIcon));

    await tap(updatePasswordIcon);
    await pumpAndSettle();

    final passwordUpdateDialogChild = find.byType(UpdateUserPasswordDialogChild);
    expect(passwordUpdateDialogChild, findsNothing, reason: 'Password update dialog should not be shown');

    await logout();
  }
}
