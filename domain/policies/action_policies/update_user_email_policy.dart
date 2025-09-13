part of 'action_policy.dart';

enum UpdateUserEmailPolicyDenialReason {
  cannotModifyAnalyst,
  canOnlyModifySelf,
}

class UpdateUserEmailPolicy extends ActionPolicy<User, User> {
  const UpdateUserEmailPolicy();

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
          return Denied(reason: UpdateUserEmailPolicyDenialReason.cannotModifyAnalyst);
      case Role.user:
        if (isModifyingSelf)
          return Granted();
        else
          return Denied(reason: UpdateUserEmailPolicyDenialReason.canOnlyModifySelf);
    }
  }
}
