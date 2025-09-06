import '../../entities/user.dart';
import '../../value_objects/role.dart';
import 'user_policy_outcome.dart';

class DeleteUserPolicy {
  const DeleteUserPolicy();

  UserPolicyOutcome canDeleteUser(
      {required User subject, required User object}) {
    switch (subject.role) {
      case Role.superAdmin:
        if (!subject.isSameAs(object))
          return Granted();
        else
          return Denied(reason: CanNotDeleteSelf());
      case Role.admin:
        if (!object.isSuperAdmin())
          return Granted();
        else
          return Denied(reason: CanNotDeleteSuperAdmin());
      case Role.user:
        if (subject.isSameAs(object))
          return Granted();
        else
          return Denied(reason: CanOnlyDeleteSelf());
    }
  }
}
