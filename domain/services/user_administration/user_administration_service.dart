import '../../entities/user.dart';
import '../../policies/policy.dart';
import '../../policies/policy_violation_exception.dart';
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
  }) : _userRepository = userRepository;

  final UserRepository _userRepository;

  final ViewUserPolicy viewUserPolicy;
  final UpdateUserEmailPolicy updateUserEmailPolicy;
  final UpdateUserPasswordPolicy updateUserPasswordPolicy;
  final DeleteUserPolicy deleteUserPolicy;

  List<User> getUsers({required User requester}) {
    var visibleUsers = <User>[];
    for (final user in _userRepository.users) {
      if (viewUserPolicy.isCompliant(requester: requester, target: user)) {
        visibleUsers.add(user);
      }
    }
    return visibleUsers;
  }

  User? get({required User requester, required Id id}) {
    final user = _userRepository.get(id: id);

    if (user == null) return null;

    final result =
        viewUserPolicy.checkCompliance(requester: requester, target: user);

    switch (result) {
      case Compliant():
        return user;
      case Violation(:final reason):
        throw PolicyViolationException(reason);
    }
  }

  User? getByEmail({required User requester, required Email email}) {
    final user = _userRepository.getByEmail(email: email);

    if (user == null) return null;

    final result =
        viewUserPolicy.checkCompliance(requester: requester, target: user);

    switch (result) {
      case Compliant():
        return user;
      case Violation(:final reason):
        throw PolicyViolationException(reason);
    }
  }

  void deleteUser({required User requester, required User target}) {
    final result =
        deleteUserPolicy.checkCompliance(requester: requester, target: target);

    switch (result) {
      case Compliant():
        _userRepository.delete(id: target.id);
      case Violation(:final reason):
        throw PolicyViolationException(reason);
    }
  }

  void updateUserEmail(
      {required User requester,
      required User target,
      required Email newEmail}) {
    final result = updateUserEmailPolicy.checkCompliance(
        requester: requester, target: target);

    switch (result) {
      case Compliant():
        _userRepository.updateEmail(id: target.id, newEmail: newEmail);
      case Violation(:final reason):
        throw PolicyViolationException(reason);
    }
  }

  void updateUserPassword(
      {required User requester,
      required User target,
      required Password newPassword}) {
    final result = updateUserPasswordPolicy.checkCompliance(
        requester: requester, target: target);

    switch (result) {
      case Compliant():
        _userRepository.updatePassword(id: target.id, newPassword: newPassword);
      case Violation(:final reason):
        throw PolicyViolationException(reason);
    }
  }
}
