import '../../entities/user.dart';
import '../../operations/operation.dart';
import '../../policies/policy.dart';
import '../../repositories/user_repository.dart';
import '../../value_objects/email.dart';
import '../../value_objects/id.dart';
import '../../value_objects/password.dart';

class UserAdministrationService {
  UserAdministrationService(UserRepository userRepository)
      : _userRepository = userRepository;

  final UserRepository _userRepository;

  List<User> getUsers(
      {required User subject, required ViewUsersOperation operation}) {
    return operation.execute(
        subject: subject,
        policy: operation.policy,
        repository: _userRepository);
  }

  User? getUser(
      {required User subject,
      required Id object,
      required ViewUserPolicy policy}) {
    final user = _userRepository.getById(object);

    if (user != null && policy.isCompliant(subject: subject, object: user)) {
      return user;
    } else {
      return null;
    }
  }

  void deleteUser(
      {required User subject,
      required User object,
      required DeleteUserPolicy policy}) {
    if (policy.isCompliant(subject: subject, object: object)) {
      _userRepository.delete(object.id);
    }
  }

  void updateUserEmail(
      {required User subject,
      required User object,
      required Email newEmail,
      required UpdateUserEmailPolicy policy}) {
    if (policy.isCompliant(subject: subject, object: object)) {
      _userRepository.updateEmail(object.id, newEmail);
    }
  }

  void updateUserPassword(
      {required User subject,
      required User object,
      required Password newPassword,
      required UpdateUserPasswordPolicy policy}) {
    if (policy.isCompliant(subject: subject, object: object)) {
      _userRepository.updatePassword(object.id, newPassword);
    }
  }
}
