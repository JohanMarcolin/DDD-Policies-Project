part of '../policy.dart';

class UpdateUserPasswordPolicy extends Policy<User, User> {
  const UpdateUserPasswordPolicy();

  @override
  PolicyPermission evaluatePermission(User initiator, User target) {
    final isModifyingSelf = initiator.isSameAs(target);

    switch (initiator.role) {
      case Role.analyst:
        return PermissionGranted();
      case Role.admin:
        if (!target.isAnalyst())
          return PermissionGranted();
        else
          return PermissionDenied(reason: CannotModifyAnalyst());
      case Role.user:
        if (isModifyingSelf)
          return PermissionGranted();
        else
          return PermissionDenied(reason: CanOnlyModifySelf());
    }
  }
}
