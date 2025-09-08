part of '../policy.dart';

class UpdateUserPasswordPolicy extends Policy<User, User> {
  const UpdateUserPasswordPolicy();

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
          return Violation(reason: CanNotModifyAnalyst());
      case Role.user:
        if (requester.isSameAs(target))
          return Compliant();
        else
          return Violation(reason: CanOnlyModifySelf());
    }
  }
}
