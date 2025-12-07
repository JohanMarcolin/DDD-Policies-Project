import 'package:domain/policies/action_authorization_policies/user_administration/user_administration_policy.dart';

import '../../entities/user.dart';
import '../../policies/validation_policies/validation_policy.dart';
import '../../repositories/user_repository.dart';
import '../../../value_objects/email.dart';
import '../../../value_objects/id.dart';
import '../../../value_objects/password.dart';

class UserAdministrationService {
  UserAdministrationService({
    required UserRepository userRepository,
    required ViewUserPolicy viewUserPolicy,
    required UpdateUserEmailPolicy updateUserEmailPolicy,
    required UpdateUserPasswordPolicy updateUserPasswordPolicy,
    required DeleteUserPolicy deleteUserPolicy,
    required this.emailValidationPolicy,
    required this.passwordValidationPolicy,
  })  : _userRepository = userRepository,
        _viewUserPolicy = viewUserPolicy,
        _updateUserEmailPolicy = updateUserEmailPolicy,
        _updateUserPasswordPolicy = updateUserPasswordPolicy,
        _deleteUserPolicy = deleteUserPolicy;

  final UserRepository _userRepository;
  final ViewUserPolicy _viewUserPolicy;
  final UpdateUserEmailPolicy _updateUserEmailPolicy;
  final UpdateUserPasswordPolicy _updateUserPasswordPolicy;
  final DeleteUserPolicy _deleteUserPolicy;
  final EmailValidationPolicy emailValidationPolicy;
  final PasswordValidationPolicy passwordValidationPolicy;

  Future<List<User>> viewUsers({required User initiator}) async {
    final users = await _userRepository.users;
    return users.where((user) => _viewUserPolicy.isAuthorized(initiator, user)).toList();
  }

  Future<User?> viewUser({required User initiator, required UserId userId}) async {
    final user = await _userRepository.get(userId: userId);

    if (user == null) return null;

    return _viewUserPolicy.enforce(initiator, user, onAuthorized: () => user);
  }

  TReturn authorizeViewUser<TReturn>({
    required User initiator,
    required User target,
    required TReturn Function() onAuthorized,
    required TReturn Function(ViewUserUnauthorizedReason) onUnauthorized,
  }) {
    return _authorizeUserAdministrationAction(initiator, target,
        policy: _viewUserPolicy, onAuthorized: onAuthorized, onUnauthorized: onUnauthorized);
  }

  Future<void> deleteUser({required User initiator, required User target}) async {
    return _deleteUserPolicy.enforce(initiator, target,
        onAuthorized: () => _userRepository.delete(userId: target.userId));
  }

  TReturn authorizeDeleteUser<TReturn>({
    required User initiator,
    required User target,
    required TReturn Function() onAuthorized,
    required TReturn Function(DeleteUserUnauthorizedReason) onUnauthorized,
  }) {
    return _authorizeUserAdministrationAction(initiator, target,
        policy: _deleteUserPolicy, onAuthorized: onAuthorized, onUnauthorized: onUnauthorized);
  }

  Future<void> updateUserEmail({required User initiator, required User target, required Email newEmail}) async {
    return _updateUserEmailPolicy.enforce(initiator, target, onAuthorized: () {
      emailValidationPolicy.enforce(newEmail);
      return _userRepository.updateEmail(userId: target.userId, newEmail: newEmail);
    });
  }

  TReturn authorizeUpdateUserEmail<TReturn>({
    required User initiator,
    required User target,
    required TReturn Function() onAuthorized,
    required TReturn Function(UpdateUserEmailUnauthorizedReason) onUnauthorized,
  }) {
    return _authorizeUserAdministrationAction(initiator, target,
        policy: _updateUserEmailPolicy, onAuthorized: onAuthorized, onUnauthorized: onUnauthorized);
  }

  Future<void> updateUserPassword(
      {required User initiator, required User target, required Password newPassword}) async {
    return _updateUserPasswordPolicy.enforce(initiator, target, onAuthorized: () {
      passwordValidationPolicy.enforce(newPassword);
      return _userRepository.updatePassword(userId: target.userId, newPassword: newPassword);
    });
  }

  TReturn authorizeUpdateUserPassword<TReturn>({
    required User initiator,
    required User target,
    required TReturn Function() onAuthorized,
    required TReturn Function(UpdateUserPasswordUnauthorizedReason) onUnauthorized,
  }) {
    return _authorizeUserAdministrationAction(initiator, target,
        policy: _updateUserPasswordPolicy, onAuthorized: onAuthorized, onUnauthorized: onUnauthorized);
  }

  TReturn _authorizeUserAdministrationAction<TReturn, TUnauthorizedReason>(
    User initiator,
    User target, {
    required UserAdministrationPolicy policy,
    required TReturn Function() onAuthorized,
    required TReturn Function(TUnauthorizedReason) onUnauthorized,
  }) {
    return policy.apply(
      actor: initiator,
      resource: target,
      onAuthorized: onAuthorized,
      onUnauthorized: (reason) => onUnauthorized(reason as TUnauthorizedReason),
    );
  }
}
