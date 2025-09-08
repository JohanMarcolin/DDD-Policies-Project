part of '../policy.dart';

class DeleteUserPolicy extends Policy<User, User> {
  const DeleteUserPolicy();

  @override
  PolicyComplianceResult checkCompliance(
      {required User requester, required User target}) {
    switch (requester.role) {
      case Role.analyst:
        if (!requester.isSameAs(target))
          return Compliant();
        else
          return Violation(reason: CanNotDeleteSelf());
      case Role.admin:
        if (!target.isAnalyst())
          return Compliant();
        else
          return Violation(reason: CanNotDeleteAnalyst());
      case Role.user:
        if (requester.isSameAs(target))
          return Compliant();
        else
          return Violation(reason: CanOnlyDeleteSelf());
    }
  }
}
