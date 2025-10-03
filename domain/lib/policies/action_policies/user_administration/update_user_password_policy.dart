part of '../action_policy.dart';

final class UpdateUserPasswordPolicy
    extends ActionPolicy<User, User, UpdateUserPasswordPermission> {
  const UpdateUserPasswordPolicy();

  @override
  bool isAuthorized(User initiator, User target) =>
      authorize(initiator, target) is UpdateUserPasswordGranted;

  @override
  UpdateUserPasswordPermission authorize(User initiator, User target) {
    final isModifyingSelf = initiator.isSameAs(target);

    switch (initiator.role) {
      case Role.analyst:
        return UpdateUserPasswordGranted();
      case Role.admin:
        if (!target.isAnalyst()) {
          return UpdateUserPasswordGranted();
        } else {
          return UpdateUserPasswordDenied(
              reason: CannotUpdatePasswordOnAnalyst());
        }
      case Role.user:
        if (isModifyingSelf) {
          return UpdateUserPasswordGranted();
        } else {
          return UpdateUserPasswordDenied(
              reason: CanOnlyUpdatePasswordOnSelf());
        }
    }
  }

  @override
  requireAuthorization(User initiator, User target,
      {required Function() onAuthorized}) {
    switch (authorize(initiator, target)) {
      case UpdateUserPasswordGranted():
        return onAuthorized();
      case UpdateUserPasswordDenied(:final reason):
        throw ActionPolicyViolationException(reason);
    }
  }
}

sealed class UpdateUserPasswordPermission {}

class UpdateUserPasswordGranted extends UpdateUserPasswordPermission {}

class UpdateUserPasswordDenied extends UpdateUserPasswordPermission {
  UpdateUserPasswordDenied({required this.reason});

  final UpdateUserPasswordDeniedReason reason;
}

sealed class UpdateUserPasswordDeniedReason {}

class CannotUpdatePasswordOnAnalyst implements UpdateUserPasswordDeniedReason {}

class CanOnlyUpdatePasswordOnSelf implements UpdateUserPasswordDeniedReason {}
