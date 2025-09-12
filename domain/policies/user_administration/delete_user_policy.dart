part of '../policy.dart';

class DeleteUserPolicy extends Policy<User, User> {
  const DeleteUserPolicy();

  @override
  PolicyPermission evaluatePermission(User initiator, User target) {
    final isDeletingSelf = initiator.isSameAs(target);

    switch (initiator.role) {
      case Role.analyst:
        if (!isDeletingSelf)
          return PermissionGranted();
        else
          return PermissionDenied(reason: CannotDeleteSelf());
      case Role.admin:
        if (!target.isAnalyst())
          return PermissionGranted();
        else
          return PermissionDenied(reason: CannotDeleteAnalyst());
      case Role.user:
        if (isDeletingSelf)
          return PermissionGranted();
        else
          return PermissionDenied(reason: CanOnlyDeleteSelf());
    }
  }
}
