import '../../entities/user.dart';
import '../../value_objects/role.dart';
import 'user_policy_outcome.dart';

class ViewUserPolicy {
  const ViewUserPolicy();

  UserPolicyOutcome canViewUser({required User subject, required User object}) {
    switch (subject.role) {
      case Role.superAdmin:
        return Granted();
      case Role.admin:
        if (!object.isSuperAdmin())
          return Granted();
        else
          return Denied(reason: CanNotViewSuperAdmin());
      case Role.user:
        if (subject.isSameAs(object))
          return Granted();
        else
          return Denied(reason: CanOnlyViewSelf());
    }
  }
}
