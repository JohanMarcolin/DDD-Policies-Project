part of '../policy.dart';

class UpdateUserEmailPolicy extends Policy<User, User> {
  const UpdateUserEmailPolicy(super.subject, super.object);

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
          return NonCompliant(reason: CanNotModifyAnalyst());
      case Role.user:
        if (subject.isSameAs(object))
          return Compliant();
        else
          return NonCompliant(reason: CanOnlyModifySelf());
    }
  }
}
