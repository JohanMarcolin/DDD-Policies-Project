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

  final ActionPolicy viewUserPolicy;
  final ActionPolicy updateUserEmailPolicy;
  final ActionPolicy updateUserPasswordPolicy;
  final ActionPolicy deleteUserPolicy;

  final ValidationPolicy emailValidationPolicy;
  final ValidationPolicy passwordValidationPolicy;

  Future<List<User>> getUsers({required User initiator}) async {
    final users = await _userRepository.users;
    return users.where(
        (targetUser) => viewUserPolicy.isPermitted(initiator, targetUser))
        .toList();
  }

  Future<User?> get({required User initiator, required UserId userId}) async {
    final user = await _userRepository.get(userId: userId);

    if (user == null) return null;

    return viewUserPolicy.enforce(initiator, user, onGranted: () => user);
  }

  Future<User?> getByEmail({required User initiator, required Email email}) async {
    final user = await _userRepository.getByEmail(email: email);

    if (user == null) return null;

    return viewUserPolicy.enforce(initiator, user, onGranted: () => user);
  }

  Future<void> deleteUser({required User initiator, required User target}) async {
    return deleteUserPolicy.enforce(initiator, target,
        onGranted: () => _userRepository.delete(userId: target.userId));
  }

  Future<void> updateUserEmail(
      {required User initiator,
      required User target,
      required Email newEmail}) async {
    emailValidationPolicy.enforce(newEmail);

    return updateUserEmailPolicy.enforce(initiator, target,
        onGranted: () =>
            _userRepository.updateEmail(userId: target.userId, newEmail: newEmail));
  }

  Future<void> updateUserPassword(
      {required User initiator,
      required User target,
      required Password newPassword}) async {
    passwordValidationPolicy.enforce(newPassword);

    return updateUserPasswordPolicy.enforce(initiator, target,
        onGranted: () => _userRepository.updatePassword(
            userId: target.userId, newPassword: newPassword));
  }
}
