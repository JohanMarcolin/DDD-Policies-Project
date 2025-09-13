part of 'action_policy.dart';

enum ViewUserPolicyDenialReason {
  cannotViewAnalyst,
  canOnlyViewSelf,
}

class ViewUserPolicy extends ActionPolicy<User, User> {
  const ViewUserPolicy();

  @override
  ActionPolicyPermission evaluatePermission(User initiator, User target) {
    final isViewingSelf = initiator.isSameAs(target);

    switch (initiator.role) {
      case Role.analyst:
        return Granted();
      case Role.admin:
        if (!target.isAnalyst())
          return Granted();
        else
          return Denied(reason: ViewUserPolicyDenialReason.cannotViewAnalyst);
      case Role.user:
        if (isViewingSelf)
          return Granted();
        else
          return Denied(reason: ViewUserPolicyDenialReason.canOnlyViewSelf);
    }
  }
}
