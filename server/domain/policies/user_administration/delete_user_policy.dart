part of '../policy.dart';

class DeleteUserPolicy extends Policy<User, User> {
  const DeleteUserPolicy(super.subject, super.object);

  @override
  PolicyComplianceResult checkCompliance(
      {required User subject, required User object}) {
    switch (subject.role) {
      case Role.analyst:
        if (!subject.isSameAs(object))
          return Compliant();
        else
          return NonCompliant(reason: CanNotDeleteSelf());
      case Role.admin:
        if (!object.isAnalyst())
          return Compliant();
        else
          return NonCompliant(reason: CanNotDeleteAnalyst());
      case Role.user:
        if (subject.isSameAs(object))
          return Compliant();
        else
          return NonCompliant(reason: CanOnlyDeleteSelf());
    }
  }
}
