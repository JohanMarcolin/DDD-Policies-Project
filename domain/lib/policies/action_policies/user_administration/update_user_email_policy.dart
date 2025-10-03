part of '../action_policy.dart';

final class UpdateUserEmailPolicy
    extends ActionPolicy<User, User, UpdateUserEmailPermission> {
  const UpdateUserEmailPolicy();

  @override
  bool isAuthorized(User initiator, User target) =>
      authorize(initiator, target) is UpdateUserEmailGranted;

  @override
  UpdateUserEmailPermission authorize(User initiator, User target) {
    final isModifyingSelf = initiator.isSameAs(target);

    switch (initiator.role) {
      case Role.analyst:
        return UpdateUserEmailGranted();
      case Role.admin:
        if (!target.isAnalyst()) {
          return UpdateUserEmailGranted();
        } else {
          return UpdateUserEmailDenied(reason: CannotUpdateEmailOnAnalyst());
        }
      case Role.user:
        if (isModifyingSelf) {
          return UpdateUserEmailGranted();
        } else {
          return UpdateUserEmailDenied(reason: CanOnlyUpdateEmailOnSelf());
        }
    }
  }

  @override
  requireAuthorization(User initiator, User target,
      {required Function() onAuthorized}) {
    switch (authorize(initiator, target)) {
      case UpdateUserEmailGranted():
        return onAuthorized();
      case UpdateUserEmailDenied(:final reason):
        throw ActionPolicyViolationException(reason);
    }
  }
}

sealed class UpdateUserEmailPermission {}

class UpdateUserEmailGranted extends UpdateUserEmailPermission {}

class UpdateUserEmailDenied extends UpdateUserEmailPermission {
  UpdateUserEmailDenied({required this.reason});

  final UpdateUserEmailDeniedReason reason;
}

sealed class UpdateUserEmailDeniedReason {}

class CannotUpdateEmailOnAnalyst implements UpdateUserEmailDeniedReason {}

class CanOnlyUpdateEmailOnSelf implements UpdateUserEmailDeniedReason {}
