part of '../policy.dart';

class ViewUserPolicy extends Policy<User, User> {
  const ViewUserPolicy(super.subject, super.object);

  @override
  PolicyComplianceResult checkCompliance(
      {required User subject, required User object}) {
    switch (subject.role) {
      case Role.analyst:
        return Compliant();
      case Role.admin:
        if (!object.isAnalyst())
          return Compliant();
        else
          return NonCompliant(reason: CanNotViewAnalyst());
      case Role.user:
        if (subject.isSameAs(object))
          return Compliant();
        else
          return NonCompliant(reason: CanOnlyViewSelf());
    }
  }
}
