part of '../policy.dart';

class ViewUserPolicy extends Policy<User, User> {
  const ViewUserPolicy();

  @override
  PolicyPermission evaluatePermission(User initiator, User target) {
    final isViewingSelf = initiator.isSameAs(target);

    switch (initiator.role) {
      case Role.analyst:
        return PermissionGranted();
      case Role.admin:
        if (!target.isAnalyst())
          return PermissionGranted();
        else
          return PermissionDenied(reason: CannotViewAnalyst());
      case Role.user:
        if (isViewingSelf)
          return PermissionGranted();
        else
          return PermissionDenied(reason: CanOnlyViewSelf());
    }
  }
}
