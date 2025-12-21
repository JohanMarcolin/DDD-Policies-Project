part of 'update_user_email_test.dart';

final _log = IntegrationTestDebugLogger(tag: 'UpdateUserEmail');
final _authorizationService = createStubbedUserAdministrationService();

/// Extension methods on [WidgetTester] for update user email scenarios.
extension _UpdateUserEmailExtension on WidgetTester {
  /// Updates the email of a target user as an initiator.
  ///
  /// Checks if the initiator is authorized to view the target user.
  /// If authorized, it proceeds to check if the initiator can update the target's email.
  /// Depending on the authorization, it either updates the email or verifies that the update is blocked.
  ///
  /// [initiator]: The user initiating the email update.
  /// [target]: The target user whose email is being updated.
  Future<void> updateUserEmail({required UserTestFixture initiator, required UserTestFixture target}) async {
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

    /// If the initiator cannot view the target, they cannot update the target's email.
    if (!canViewTarget) return;

    await _authorizationService.authorizeUpdateUserEmail(
      initiator: initiator.user,
      target: target.user,
      onAuthorized: () async {
        _log.authorized('$initiatorRole authorized to update email for $targetRole');
        await _verifyUpdateUserEmailSucceeds(initiator: initiator, target: target);
      },
      onUnauthorized: (_) async {
        _log.unauthorized('$initiatorRole unauthorized to update email for $targetRole');
        await _verifyUpdateUserEmailIsBlocked(initiator: initiator, target: target);
      },
    );
  }

  /// Verifies that updating a user's email succeeds.
  ///
  /// Logs in as the initiator, verifies the target user's current email, updates the email, and ensures the old email
  /// cannot be used to log in. Verifies login with the new email.
  ///
  /// [initiator]: The user initiating the email update.
  /// [target]: The target user whose email is being updated.
  Future<void> _verifyUpdateUserEmailSucceeds({
    required UserTestFixture initiator,
    required UserTestFixture target,
  }) async {
    var targetUserId = target.user.userId;
    var targetUserRole = target.user.role.name;
    var targetEmail = target.user.email;
    var targetPassword = target.password;

    await startApp();

    await login(email: initiator.email, password: initiator.password);

    final targetUserTile = findUserTileByUserId(targetUserId);
    expect(targetUserTile, findsOne, reason: 'UserTile should be found for $targetUserRole target');

    final targetUserTileWidget = widget<UserTile>(targetUserTile);
    expect(
      targetUserTileWidget.user.email,
      equals(targetEmail),
      reason: 'Target UserTile should show correct email before update',
    );

    final updateEmailIcon = find.descendant(of: targetUserTile, matching: find.byType(UpdateUserEmailIcon));

    await tap(updateEmailIcon);
    await pumpAndSettle();

    final emailUpdateDialogChild = find.byType(UpdateUserEmailDialogChild);
    expect(emailUpdateDialogChild, findsOne, reason: 'Email update dialog should be shown');

    final confirmInputDialog = find.descendant(of: emailUpdateDialogChild, matching: find.byType(ConfirmInputDialog));

    expect(confirmInputDialog, findsOne, reason: 'Confirm input dialog should be shown');

    final emailField = find.descendant(of: confirmInputDialog, matching: find.byType(TextField));

    final newTargetEmail = mockValidEmail;

    await enterText(emailField, newTargetEmail.value);

    final confirmButton = findConfirmButton();

    await tap(confirmButton);

    final isEmailUpdated = await _isEmailUpdatedInTargetUserTile(
      targetUserId: targetUserId,
      newTargetEmail: newTargetEmail,
    );

    expect(isEmailUpdated, isTrue, reason: 'Target UserTile should show correct email after update');

    await logout();

    final oldTargetEmail = targetEmail;

    await login(email: oldTargetEmail, password: targetPassword);

    expect(
      find.byType(UserAdministrationView),
      findsNothing,
      reason: 'Login with old target email should fail after email update for $targetUserRole',
    );

    await login(email: newTargetEmail, password: targetPassword);

    expect(
      find.byType(UserAdministrationView),
      findsOne,
      reason: 'Login with new email should succeed after email update for $targetUserRole',
    );

    await logout();
  }

  /// Waits for the target user's tile to reflect the updated email.
  ///
  /// Repeatedly checks the target user's tile until the email is updated
  /// or a timeout occurs.
  ///
  /// [targetUserId]: The ID of the target user whose email is being updated.
  /// [newTargetEmail]: The new email to verify in the target user's tile.
  /// [timeout]: The maximum duration to wait for the email update.
  ///
  /// `Note:` The default [timeout] is likely excessive, but was set to avoid flakiness due to
  /// potential performance differences in Android emulators. Further optimization of the client app
  /// may allow for a reduced or removed timeout, but this lies outside the scope of the current project.
  Future<bool> _isEmailUpdatedInTargetUserTile({
    required UserId targetUserId,
    required Email newTargetEmail,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final startTime = DateTime.now();

    while (!_isTimedOut(startTime, timeout)) {
      await pumpAndSettle();
      if (_isEmailUpdateVerified(targetUserId, newTargetEmail)) return true;
    }
    fail('Target UserTile did not show updated email within ${timeout.inSeconds} seconds');
  }

  /// Checks if the timeout duration has been exceeded.
  /// [startTime]: The start time of the operation.
  /// [timeout]: The maximum allowed duration.
  bool _isTimedOut(DateTime startTime, Duration timeout) {
    return DateTime.now().difference(startTime) > timeout;
  }

  /// Verifies if the target user's tile shows the updated email.
  /// [targetUserId]: The ID of the target user.
  /// [newTargetEmail]: The new email to verify in the target user's tile.
  bool _isEmailUpdateVerified(UserId targetUserId, Email newTargetEmail) {
    final targetUserTile = findUserTileByUserId(targetUserId);
    final targetUserTileWidget = widget<UserTile>(targetUserTile);
    return targetUserTileWidget.user.email == newTargetEmail;
  }

  /// Verifies that updating a user's email is blocked.
  ///
  /// Verifies that the email update dialog is not shown
  /// when the initiator is unauthorized to update the target's email.
  ///
  /// [initiator]: The user initiating the email update.
  /// [target]: The target user whose email update is being blocked.
  Future<void> _verifyUpdateUserEmailIsBlocked({
    required UserTestFixture initiator,
    required UserTestFixture target,
  }) async {
    await startApp();

    await login(email: initiator.email, password: initiator.password);

    final targetUserTile = findUserTileByUserId(target.user.userId);
    expect(targetUserTile, findsOne, reason: 'UserTile should be found for ${target.user.role.name} target');

    final updateEmailIcon = find.descendant(of: targetUserTile, matching: find.byType(UpdateUserEmailIcon));

    await tap(updateEmailIcon);
    await pumpAndSettle();

    final emailUpdateDialogChild = find.byType(UpdateUserEmailDialogChild);
    expect(emailUpdateDialogChild, findsNothing, reason: 'Email update dialog should not be shown');

    await logout();
  }
}
