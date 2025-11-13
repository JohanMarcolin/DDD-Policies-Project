import '../../entities/user.dart';
import '../../policies/action_policies/action_policy.dart';
import '../../policies/validation_policies/validation_policy.dart';
import '../../repositories/user_repository.dart';
import '../../../value_objects/email.dart';
import '../../../value_objects/id.dart';
import '../../../value_objects/password.dart';

class UserAdministrationService {
  UserAdministrationService({
    required UserRepository userRepository,
    required this.viewUserPolicy,
    required this.updateUserEmailPolicy,
    required this.updateUserPasswordPolicy,
    required this.deleteUserPolicy,
    required this.emailValidationPolicy,
    required this.passwordValidationPolicy,
  }) : _userRepository = userRepository;

  final UserRepository _userRepository;

  final ViewUserPolicy viewUserPolicy;
  final UpdateUserEmailPolicy updateUserEmailPolicy;
  final UpdateUserPasswordPolicy updateUserPasswordPolicy;
  final DeleteUserPolicy deleteUserPolicy;

  final EmailValidationPolicy emailValidationPolicy;
  final PasswordValidationPolicy passwordValidationPolicy;

  Future<List<User>> viewUsers({required User initiator}) async {
    final users = await _userRepository.users;
    return users.where((targetUser) => viewUserPolicy.isAuthorized(initiator, targetUser)).toList();
  }

  Future<User?> viewUser({required User initiator, required UserId userId}) async {
    final user = await _userRepository.get(userId: userId);

    if (user == null) return null;

    return viewUserPolicy.requireAuthorization(initiator, user, onAuthorized: () => user);
  }

  Future<void> deleteUser({required User initiator, required User target}) async {
    return deleteUserPolicy.requireAuthorization(initiator, target,
        onAuthorized: () => _userRepository.delete(userId: target.userId));
  }

  Future<void> updateUserEmail({required User initiator, required User target, required Email newEmail}) async {
    emailValidationPolicy.enforce(newEmail);

    return updateUserEmailPolicy.requireAuthorization(initiator, target,
        onAuthorized: () => _userRepository.updateEmail(userId: target.userId, newEmail: newEmail));
  }

  Future<void> updateUserPassword(
      {required User initiator, required User target, required Password newPassword}) async {
    passwordValidationPolicy.enforce(newPassword);

    return updateUserPasswordPolicy.requireAuthorization(initiator, target,
        onAuthorized: () => _userRepository.updatePassword(userId: target.userId, newPassword: newPassword));
  }
}
