import '../../entities/user.dart';
import '../../policies/user_administration/user_policy_outcome.dart';
import '../../value_objects/id.dart';

sealed class UserAdministrationOutcome {
}

class ViewUserSuccess extends UserAdministrationOutcome {
  ViewUserSuccess({required this.user});

  final User user;
}

class ViewUserDenied extends UserAdministrationOutcome {
  ViewUserDenied({required this.reason});

  final UserPolicyDenialReason reason;
}

class UserNotFound extends UserAdministrationOutcome {
  UserNotFound({required this.id});

  final Id id;
}

class DeleteUserSuccess extends UserAdministrationOutcome {}

class DeleteUserDenied extends UserAdministrationOutcome {
  DeleteUserDenied({required this.reason});

  final UserPolicyDenialReason reason;
}

class UpdateUserEmailSuccess extends UserAdministrationOutcome {}

class UpdateUserEmailDenied extends UserAdministrationOutcome {
  UpdateUserEmailDenied({required this.reason});

  final UserPolicyDenialReason reason;
}

class UpdateUserPasswordSuccess extends UserAdministrationOutcome {}

class UpdateUserPasswordDenied extends UserAdministrationOutcome {
  UpdateUserPasswordDenied({required this.reason});

  final UserPolicyDenialReason reason;
}
