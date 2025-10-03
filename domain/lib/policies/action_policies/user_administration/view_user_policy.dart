part of '../action_policy.dart';

final class ViewUserPolicy
    extends ActionPolicy<User, User, ViewUserPermission> {
  const ViewUserPolicy();

  @override
  bool isAuthorized(User initiator, User target) =>
      authorize(initiator, target) is ViewUserGranted;

  @override
  ViewUserPermission authorize(User initiator, User target) {
    switch (initiator.role) {
      case Role.analyst:
        return ViewUserGranted();
      case Role.admin:
      case Role.user:
        if (!target.isAnalyst()) {
          return ViewUserGranted();
        } else {
          return ViewUserDenied(reason: CannotViewAnalyst());
        }
    }
  }

  @override
  requireAuthorization(User initiator, User target,
      {required Function() onAuthorized}) {
    switch (authorize(initiator, target)) {
      case ViewUserGranted():
        return onAuthorized();
      case ViewUserDenied(:final reason):
        throw ActionPolicyViolationException(reason);
    }
  }
}

sealed class ViewUserPermission {}

class ViewUserGranted extends ViewUserPermission {}

class ViewUserDenied extends ViewUserPermission {
  ViewUserDenied({required this.reason});

  final ViewUserDeniedReason reason;
}

sealed class ViewUserDeniedReason {}

class CannotViewAnalyst implements ViewUserDeniedReason {}
