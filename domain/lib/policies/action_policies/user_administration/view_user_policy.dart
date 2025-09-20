part of '../action_policy.dart';

class ViewUserPolicy extends ActionPolicy<User, User> {
  const ViewUserPolicy();

  @override
  ActionPolicyPermission evaluatePermission(User initiator, User target) {
    switch (initiator.role) {
      case Role.analyst:
        return Granted();
      case Role.admin:
        if (!target.isAnalyst()) {
          return Granted();
        } else {
          return Denied(reason: CannotViewAnalyst());
        }
      case Role.user:
        if (!target.isAnalyst()) {
          return Granted();
        } else {
          return Denied(reason: CanOnlyViewSelf());
        }
    }
  }
}

sealed class ViewUserDeniedReason {}

class CannotViewAnalyst implements ViewUserDeniedReason {
  @override
  String toString() => 'Cannot view analyst.';
}

class CanOnlyViewSelf implements ViewUserDeniedReason {
  @override
  String toString() => 'Can only view self.';
}
