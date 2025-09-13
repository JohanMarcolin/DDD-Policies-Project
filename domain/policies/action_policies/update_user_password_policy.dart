part of 'action_policy.dart';

enum UpdateUserPasswordPolicyDenialReason {
  cannotModifyAnalyst,
  canOnlyModifySelf,
}

class UpdateUserPasswordPolicy extends ActionPolicy<User, User> {
  const UpdateUserPasswordPolicy();

  @override
  ActionPolicyPermission evaluatePermission(User initiator, User target) {
    final isModifyingSelf = initiator.isSameAs(target);

    switch (initiator.role) {
      case Role.analyst:
        return Granted();
      case Role.admin:
        if (!target.isAnalyst())
          return Granted();
        else
          return Denied(reason: UpdateUserPasswordPolicyDenialReason.cannotModifyAnalyst);
      case Role.user:
        if (isModifyingSelf)
          return Granted();
        else
          return Denied(reason: UpdateUserPasswordPolicyDenialReason.canOnlyModifySelf);
    }
  }
}
