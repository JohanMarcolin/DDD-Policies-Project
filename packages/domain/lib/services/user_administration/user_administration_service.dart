import 'package:domain/policies/action_authorization_policies/user_administration/user_administration_policy.dart';
import 'package:domain/policies/value_validation_policies/user_credentials/user_credential_policy.dart';
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';
import '../../../value_objects/email.dart';
import '../../../value_objects/id.dart';
import '../../../value_objects/password.dart';

/// Service for user administration with policy enforcement and validation.
class UserAdministrationService {
  UserAdministrationService({
    required UserRepository userRepository,
    required ViewUserPolicy viewUserPolicy,
    required UpdateUserEmailPolicy updateUserEmailPolicy,
    required UpdateUserPasswordPolicy updateUserPasswordPolicy,
    required DeleteUserPolicy deleteUserPolicy,
    required UserEmailValidationPolicy userEmailValidationPolicy,
    required UserPasswordValidationPolicy userPasswordValidationPolicy,
  })  : _userRepository = userRepository,
        _viewUserPolicy = viewUserPolicy,
        _updateUserEmailPolicy = updateUserEmailPolicy,
        _updateUserPasswordPolicy = updateUserPasswordPolicy,
        _deleteUserPolicy = deleteUserPolicy,
        _userEmailValidationPolicy = userEmailValidationPolicy,
        _userPasswordValidationPolicy = userPasswordValidationPolicy;

  final UserRepository _userRepository;
  final ViewUserPolicy _viewUserPolicy;
  final UpdateUserEmailPolicy _updateUserEmailPolicy;
  final UpdateUserPasswordPolicy _updateUserPasswordPolicy;
  final DeleteUserPolicy _deleteUserPolicy;
  final UserEmailValidationPolicy _userEmailValidationPolicy;
  final UserPasswordValidationPolicy _userPasswordValidationPolicy;

  /// Returns all users the [initiator] is authorized to view, as determined by [ViewUserPolicy].
  ///
  /// [initiator] The user requesting to view users.
  ///
  /// Returns a [Future] containing the list of authorized [User]s.
  Future<List<User>> viewUsers({required User initiator}) async {
    final users = await _userRepository.users;
    return users.where((user) => _viewUserPolicy.isAuthorized(initiator, user)).toList();
  }

  /// Returns the [User] with [userId] if they exist and [initiator] is authorized to view them.
  ///
  /// [initiator] The user requesting to view another user.
  /// [userId] The ID of the user to view.
  ///
  /// Returns a [Future] containing the [User] if authorized, or null if not found.
  ///
  /// Throws [PolicyViolationException]<[ViewUserUnauthorizedReason]> if [initiator] is not authorized to view the user.
  Future<User?> viewUser({required User initiator, required UserId userId}) async {
    final user = await _userRepository.get(userId: userId);

    if (user == null) return null;

    return _viewUserPolicy.enforce(initiator, user, onAuthorized: () => user);
  }

  /// Applies [ViewUserPolicy] to determine if [initiator] is authorized to view [target].
  ///
  /// [initiator] The user requesting to view another user.
  /// [target] The user to be viewed.
  /// [onAuthorized] Callback invoked if authorized.
  /// [onUnauthorized] Callback invoked with reason if unauthorized.
  ///
  /// Returns [TReturn] from the invoked callback.
  TReturn authorizeViewUser<TReturn>({
    required User initiator,
    required User target,
    required TReturn Function() onAuthorized,
    required TReturn Function(ViewUserUnauthorizedReason) onUnauthorized,
  }) {
    return _viewUserPolicy.apply(
        actor: initiator, resource: target, onAuthorized: onAuthorized, onUnauthorized: onUnauthorized);
  }

  /// Deletes [target] if [initiator] is authorized, as determined by [DeleteUserPolicy].
  ///
  /// [initiator] The user requesting the deletion.
  /// [target] The user to be deleted.
  ///
  /// Returns a [Future] that completes when the user is deleted.
  ///
  /// Throws [PolicyViolationException]<[DeleteUserUnauthorizedReason]> if [initiator] is not authorized to delete the user.
  Future<void> deleteUser({required User initiator, required User target}) async {
    return _deleteUserPolicy.enforce(initiator, target,
        onAuthorized: () => _userRepository.delete(userId: target.userId));
  }

  /// Applies [DeleteUserPolicy] to determine if [initiator] is authorized to delete [target].
  ///
  /// [initiator] The user requesting the deletion.
  /// [target] The user to be deleted.
  /// [onAuthorized] Callback invoked if authorized.
  /// [onUnauthorized] Callback invoked with reason if unauthorized.
  ///
  /// Returns [TReturn] from the invoked callback.
  TReturn authorizeDeleteUser<TReturn>({
    required User initiator,
    required User target,
    required TReturn Function() onAuthorized,
    required TReturn Function(DeleteUserUnauthorizedReason) onUnauthorized,
  }) {
    return _deleteUserPolicy.apply(
      actor: initiator,
      resource: target,
      onAuthorized: onAuthorized,
      onUnauthorized: onUnauthorized,
    );
  }

  /// Updates [target]'s email to [newEmail] if [initiator] is authorized and the email is valid.
  ///
  /// [initiator] The user requesting the update.
  /// [target] The user whose email is being updated.
  /// [newEmail] The new email address.
  ///
  /// Returns a [Future] that completes when the email is updated.
  ///
  /// Throws [PolicyViolationException]<[UpdateUserEmailUnauthorizedReason]> if not authorized, or [PolicyViolationException]<[EmailInvalidReason]> if the email is invalid.
  Future<void> updateUserEmail({required User initiator, required User target, required Email newEmail}) async {
    return _updateUserEmailPolicy.enforce(initiator, target, onAuthorized: () {
      _userEmailValidationPolicy.enforce(newEmail, onValid: () {
        return _userRepository.updateEmail(userId: target.userId, newEmail: newEmail);
      });
    });
  }

  /// Validates [email] using [UserEmailValidationPolicy].
  ///
  /// [email] The email to validate.
  /// [onValid] Callback invoked if valid.
  /// [onInvalid] Callback invoked with reason if invalid.
  ///
  /// Returns [TReturn] from the invoked callback.
  TReturn validateUserEmail<TReturn>(
    Email email, {
    required TReturn Function() onValid,
    required TReturn Function(EmailInvalidReason) onInvalid,
  }) {
    return _userEmailValidationPolicy.apply(
      value: email,
      onValid: onValid,
      onInvalid: (reason) => onInvalid(reason),
    );
  }

  /// Applies [UpdateUserEmailPolicy] to determine if [initiator] is authorized to update [target]'s email.
  ///
  /// [initiator] The user requesting the update.
  /// [target] The user whose email is being updated.
  /// [onAuthorized] Callback invoked if authorized.
  /// [onUnauthorized] Callback invoked with reason if unauthorized.
  ///
  /// Returns [TReturn] from the invoked callback.
  TReturn authorizeUpdateUserEmail<TReturn>({
    required User initiator,
    required User target,
    required TReturn Function() onAuthorized,
    required TReturn Function(UpdateUserEmailUnauthorizedReason) onUnauthorized,
  }) {
    return _updateUserEmailPolicy.apply(
      actor: initiator,
      resource: target,
      onAuthorized: onAuthorized,
      onUnauthorized: onUnauthorized,
    );
  }

  /// Updates [target]'s password to [newPassword] if [initiator] is authorized and the password is valid.
  ///
  /// [initiator] The user requesting the update.
  /// [target] The user whose password is being updated.
  /// [newPassword] The new password.
  ///
  /// Returns a [Future] that completes when the password is updated.
  ///
  /// Throws [PolicyViolationException]<[UpdateUserPasswordUnauthorizedReason]> if not authorized, or [PolicyViolationException]<[PasswordInvalidReason]> if the password is invalid.
  Future<void> updateUserPassword(
      {required User initiator, required User target, required Password newPassword}) async {
    return _updateUserPasswordPolicy.enforce(initiator, target, onAuthorized: () {
      _userPasswordValidationPolicy.enforce(newPassword, onValid: () {
        return _userRepository.updatePassword(userId: target.userId, newPassword: newPassword);
      });
    });
  }

  /// Validates [password] using [UserPasswordValidationPolicy].
  ///
  /// [password] The password to validate.
  /// [onValid] Callback invoked if valid.
  /// [onInvalid] Callback invoked with reason if invalid.
  ///
  /// Returns [TReturn] from the invoked callback.
  TReturn validateUserPassword<TReturn>(
    Password password, {
    required TReturn Function() onValid,
    required TReturn Function(PasswordInvalidReason) onInvalid,
  }) {
    return _userPasswordValidationPolicy.apply(
      value: password,
      onValid: onValid,
      onInvalid: (reason) => onInvalid(reason),
    );
  }

  /// Generates a random [Password] that satisfies the password policy.
  ///
  /// Returns a valid [Password].
  Password generateUserPassword() {
    return _userPasswordValidationPolicy.generateRandomPassword();
  }

  /// Applies [UpdateUserPasswordPolicy] to determine if [initiator] is authorized to update [target]'s password.
  ///
  /// [initiator] The user requesting the update.
  /// [target] The user whose password is being updated.
  /// [onAuthorized] Callback invoked if authorized.
  /// [onUnauthorized] Callback invoked with reason if unauthorized.
  ///
  /// Returns [TReturn] from the invoked callback.
  TReturn authorizeUpdateUserPassword<TReturn>({
    required User initiator,
    required User target,
    required TReturn Function() onAuthorized,
    required TReturn Function(UpdateUserPasswordUnauthorizedReason) onUnauthorized,
  }) {
    return _updateUserPasswordPolicy.apply(
      actor: initiator,
      resource: target,
      onAuthorized: onAuthorized,
      onUnauthorized: onUnauthorized,
    );
  }
}
