part of 'update_user_email_test.dart';

final log = IntegrationTestDebugLogger(tag: 'UpdateUserEmail');
final userAdministrationService = createStubbedUserAdministrationService();

/// Extension methods on [WidgetTester] for update user email scenarios.
extension _UpdateUserEmailExtension on WidgetTester {
  /// Updates the email of a target user as an initiator.
  ///
  /// This method first checks if the initiator is authorized to view the target user.
  /// If authorized, it proceeds to check if the initiator can update the target's email.
  /// Depending on the authorization, it either updates the email or asserts that the update is blocked.
  ///
  /// [initiator]: The user initiating the email update.
  /// [target]: The target user whose email is being updated.
  Future<void> updateUserEmail({required UserTestFixture initiator, required UserTestFixture target}) async {
    final initiatorRole = initiator.user.role.name;
    final targetRole = initiator.user.isSameAs(target.user) ? 'self' : target.user.role.name;

    final canViewTarget = await userAdministrationService.authorizeViewUser(
      initiator: initiator.user,
      target: target.user,
      onAuthorized: () async {
        log.authorized('$initiatorRole authorized to view $targetRole');
        await assertUserTileIsVisible(initiator: initiator, target: target);
        return true;
      },
      onUnauthorized: (_) async {
        log.unauthorized('$initiatorRole unauthorized to view $targetRole');
        await assertUserTileIsNotVisible(initiator: initiator, target: target);
        return false;
      },
    );

    /// If the initiator cannot view the target, they cannot update the target's email.
    if (!canViewTarget) return;

    await userAdministrationService.authorizeUpdateUserEmail(
      initiator: initiator.user,
      target: target.user,
      onAuthorized: () async {
        log.authorized('$initiatorRole authorized to update email for $targetRole');
        await _assertUpdateUserEmailSucceeds(initiator: initiator, target: target);
      },
      onUnauthorized: (_) async {
        log.unauthorized('$initiatorRole unauthorized to update email for $targetRole');
        await _assertUpdateUserEmailIsBlocked(initiator: initiator, target: target);
      },
    );
  }

  /// Asserts that updating a user's email succeeds.
  ///
  /// This method performs the following steps:
  /// - Logs in as the initiator.
  /// - Finds the target user's tile and verifies the current email.
  /// - Updates the email and verifies the update.
  /// - Ensures the old email cannot be used to log in.
  /// - Verifies login with the new email.
  ///
  /// [initiator]: The user initiating the email update.
  /// [target]: The target user whose email is being updated.
  Future<void> _assertUpdateUserEmailSucceeds({
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
  /// This method repeatedly checks the target user's tile until the email is updated
  /// or a timeout occurs.
  ///
  /// [targetUserId]: The ID of the target user whose email is being updated.
  /// [newTargetEmail]: The new email to verify in the target user's tile.
  /// [timeout]: The maximum duration to wait for the email update.
  /// `Note:` The default [timeout] is likely excessive, but was set to avoid flakiness due to
  /// performance differences in Android emulators. Further optimization of the client app
  /// may allow for a reduced or removed timeout, although this lies outside the scope of
  /// the current project.
  Future<bool> _isEmailUpdatedInTargetUserTile({
    required UserId targetUserId,
    required Email newTargetEmail,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final startTime = DateTime.now();

    while (!_isTimedOut(startTime, timeout)) {
      await pumpAndSettle();
      if (_isEmailUpdated(targetUserId, newTargetEmail)) return true;
    }
    fail('Target UserTile did not show updated email within ${timeout.inSeconds} seconds');
  }

  /// Checks if the timeout duration has been exceeded.
  /// [startTime]: The start time of the operation.
  /// [timeout]: The maximum allowed duration.
  bool _isTimedOut(DateTime startTime, Duration timeout) {
    return DateTime.now().difference(startTime) > timeout;
  }

  /// Checks if the target user's tile shows the updated email.
  /// [targetUserId]: The ID of the target user.
  /// [newTargetEmail]: The new email to verify in the target user's tile.
  bool _isEmailUpdated(UserId targetUserId, Email newTargetEmail) {
    final targetUserTile = findUserTileByUserId(targetUserId);
    final targetUserTileWidget = widget<UserTile>(targetUserTile);
    return targetUserTileWidget.user.email == newTargetEmail;
  }

  /// Asserts that updating a user's email is blocked.
  ///
  /// This method verifies that the email update dialog is not shown
  /// when the initiator is unauthorized to update the target's email.
  ///
  /// [initiator]: The user initiating the email update.
  /// [target]: The target user whose email update is being blocked.
  Future<void> _assertUpdateUserEmailIsBlocked({
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
