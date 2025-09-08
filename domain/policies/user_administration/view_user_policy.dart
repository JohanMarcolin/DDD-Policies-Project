part of '../policy.dart';

class ViewUserPolicy extends Policy<User, User> {
  const ViewUserPolicy();

  @override
  PolicyComplianceResult checkCompliance(
      {required User requester, required User target}) {
    switch (requester.role) {
      case Role.analyst:
        return Compliant();
      case Role.admin:
        if (!target.isAnalyst())
          return Compliant();
        else
          return Violation(reason: CanNotViewAnalyst());
      case Role.user:
        if (requester.isSameAs(target))
          return Compliant();
        else
          return Violation(reason: CanOnlyViewSelf());
    }
  }
}
