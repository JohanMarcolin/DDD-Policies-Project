import '../../entities/user.dart';
import '../../policies/action_policies/action_policy.dart';
import '../../policies/validation_policies/validation_policy.dart';
import '../../repositories/user_repository.dart';
import '../../value_objects/email.dart';
import '../../value_objects/id.dart';
import '../../value_objects/password.dart';

class UserAdministrationService {
  UserAdministrationService({
    required UserRepository userRepository,
    required this.viewUserPolicy,
    required this.updateUserEmailPolicy,
    required this.updateUserPasswordPolicy,
    required this.deleteUserPolicy,
    required this.validateEmailPolicy,
    required this.validatePasswordPolicy,
  }) : _userRepository = userRepository;

  final UserRepository _userRepository;

  final ViewUserPolicy viewUserPolicy;
  final UpdateUserEmailPolicy updateUserEmailPolicy;
  final UpdateUserPasswordPolicy updateUserPasswordPolicy;
  final DeleteUserPolicy deleteUserPolicy;

  final ValidateEmailPolicy validateEmailPolicy;
  final ValidatePasswordPolicy validatePasswordPolicy;

  List<User> getUsers({required User initiator}) {
    return _userRepository.users
        .where(
            (targetUser) => viewUserPolicy.isPermitted(initiator, targetUser))
        .toList();
  }

  User? get({required User initiator, required Id id}) {
    final user = _userRepository.get(id: id);

    if (user == null) return null;

    return viewUserPolicy.enforce(initiator, user, onGranted: () => user);
  }

  User? getByEmail({required User initiator, required Email email}) {
    final user = _userRepository.getByEmail(email: email);

    if (user == null) return null;

    return viewUserPolicy.enforce(initiator, user, onGranted: () => user);
  }

  void deleteUser({required User initiator, required User target}) {
    return deleteUserPolicy.enforce(initiator, target,
        onGranted: () => _userRepository.delete(id: target.id));
  }

  void updateUserEmail(
      {required User initiator,
      required User target,
      required Email newEmail}) {
    validateEmailPolicy.enforce(newEmail);

    return updateUserEmailPolicy.enforce(initiator, target,
        onGranted: () =>
            _userRepository.updateEmail(id: target.id, newEmail: newEmail));
  }

  void updateUserPassword(
      {required User initiator,
      required User target,
      required Password newPassword}) {
    validatePasswordPolicy.enforce(newPassword);

    return updateUserPasswordPolicy.enforce(initiator, target,
        onGranted: () => _userRepository.updatePassword(
            id: target.id, newPassword: newPassword));
  }
}
