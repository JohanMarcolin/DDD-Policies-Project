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

  Future<List<User>> getUsers({required User initiator}) async {
    final users = await _userRepository.users;
    return users
        .where(
            (targetUser) => viewUserPolicy.isPermitted(initiator, targetUser))
        .toList();
  }

  Future<User?> get({required User initiator, required UserId userId}) async {
    final user = await _userRepository.get(userId: userId);

    if (user == null) return null;

    return viewUserPolicy.enforce(initiator, user, onGranted: () => user);
  }

  Future<User?> getByEmail(
      {required User initiator, required Email email}) async {
    final user = await _userRepository.getByEmail(email: email);

    if (user == null) return null;

    return viewUserPolicy.enforce(initiator, user, onGranted: () => user);
  }

  Future<void> deleteUser(
      {required User initiator, required UserId userId}) async {
    final user = await _userRepository.get(userId: userId);

    if (user == null) return;

    return deleteUserPolicy.enforce(initiator, user,
        onGranted: () => _userRepository.delete(userId: user.userId));
  }

  Future<void> updateUserEmail(
      {required User initiator,
      required UserId userId,
      required Email newEmail}) async {
    emailValidationPolicy.enforce(newEmail);

    final user = await _userRepository.get(userId: userId);

    if (user == null) return;

    return updateUserEmailPolicy.enforce(initiator, user,
        onGranted: () => _userRepository.updateEmail(
            userId: user.userId, newEmail: newEmail));
  }

  Future<void> updateUserPassword(
      {required User initiator,
      required UserId userId,
      required Password newPassword}) async {
    passwordValidationPolicy.enforce(newPassword);

    final user = await _userRepository.get(userId: userId);

    if (user == null) return;

    return updateUserPasswordPolicy.enforce(initiator, user,
        onGranted: () => _userRepository.updatePassword(
            userId: user.userId, newPassword: newPassword));
  }
}
