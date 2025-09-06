import '../../entities/user.dart';
import '../../policies/user_administration/delete_user_policy.dart';
import '../../policies/user_administration/update_user_email_policy.dart';
import '../../policies/user_administration/update_user_password_policy.dart';
import '../../policies/user_administration/user_policy_outcome.dart';
import '../../policies/user_administration/view_user_policy.dart';
import '../../repositories/user_repository.dart';
import '../../value_objects/email.dart';
import '../../value_objects/id.dart';
import '../../value_objects/password.dart';
import 'user_administration_outcome.dart';

class UserAdministrationService {
  UserAdministrationService(UserRepository userRepository)
      : _userRepository = userRepository;

  final UserRepository _userRepository;

  UserAdministrationOutcome viewUser(
      User subject, Id object, ViewUserPolicy policy) {
    final user = _userRepository.getById(object);

    if (user == null) return UserNotFound(id: object);

    switch (policy.canViewUser(subject: subject, object: user)) {
      case Granted():
        return ViewUserSuccess(user: user);
      case Denied(reason: final reason):
        return ViewUserDenied(reason: reason);
    }
  }

  UserAdministrationOutcome deleteUser(
      User subject, User object, DeleteUserPolicy policy) {
    switch (policy.canDeleteUser(subject: subject, object: object)) {
      case Granted():
        _userRepository.delete(object.id);
        return DeleteUserSuccess();
      case Denied(reason: final reason):
        return DeleteUserDenied(reason: reason);
    }
  }

  UserAdministrationOutcome updateUserEmail(
      User subject, User object, Email newEmail, UpdateUserEmailPolicy policy) {
    switch (policy.canUpdateUserEmail(subject: subject, object: object)) {
      case Granted():
        _userRepository.updateEmail(object.id, newEmail);
        return UpdateUserEmailSuccess();
      case Denied(reason: final reason):
        return UpdateUserEmailDenied(reason: reason);
    }
  }

  UserAdministrationOutcome updateUserPassword(
      User subject, User object, Password newPassword, UpdateUserPasswordPolicy policy) {
    switch (policy.canModifyUserPassword(subject: subject, object: object)) {
      case Granted():
        _userRepository.updatePassword(object.id, newPassword);
        return UpdateUserPasswordSuccess();
      case Denied(reason: final reason):
        return UpdateUserPasswordDenied(reason: reason);
    }
  }
}
