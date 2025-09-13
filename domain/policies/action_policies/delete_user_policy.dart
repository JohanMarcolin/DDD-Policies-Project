part of 'action_policy.dart';

enum DeleteUserPolicyDenialReason {
  cannotDeleteSelf,
  cannotDeleteAnalyst,
  canOnlyDeleteSelf,
}

class DeleteUserPolicy extends ActionPolicy<User, User> {
  const DeleteUserPolicy();

  @override
  ActionPolicyPermission evaluatePermission(User initiator, User target) {
    final isDeletingSelf = initiator.isSameAs(target);

    switch (initiator.role) {
      case Role.analyst:
        if (!isDeletingSelf)
          return Granted();
        else
          return Denied(reason: DeleteUserPolicyDenialReason.cannotDeleteSelf);
      case Role.admin:
        if (!target.isAnalyst())
          return Granted();
        else
          return Denied(reason: DeleteUserPolicyDenialReason.cannotDeleteAnalyst);
      case Role.user:
        if (isDeletingSelf)
          return Granted();
        else
          return Denied(reason: DeleteUserPolicyDenialReason.canOnlyDeleteSelf);
    }
  }
}