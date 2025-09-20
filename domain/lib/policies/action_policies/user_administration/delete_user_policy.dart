part of '../action_policy.dart';

class DeleteUserPolicy extends ActionPolicy<User, User> {
  const DeleteUserPolicy();

  @override
  ActionPolicyPermission evaluatePermission(User initiator, User target) {
    final isDeletingSelf = initiator.isSameAs(target);

    switch (initiator.role) {
      case Role.analyst:
        if (target.isAnalyst() && !isDeletingSelf) {
          return Denied(reason: CanOnlyDeleteSelf());
        } else {
          return Granted();
        }
      case Role.admin:
        if (!target.isAnalyst()) {
          return Granted();
        } else {
          return Denied(reason: CannotDeleteAnalyst());
        }
      case Role.user:
        if (isDeletingSelf) {
          return Granted();
        } else {
          return Denied(reason: CanOnlyDeleteSelf());
        }
    }
  }
}

sealed class DeleteUserDeniedReason {}

class CannotDeleteSelf implements DeleteUserDeniedReason {
  @override
  String toString() => 'Cannot delete self.';
}

class CannotDeleteAnalyst implements DeleteUserDeniedReason {
  @override
  String toString() => 'Cannot delete analyst.';
}

class CanOnlyDeleteSelf implements DeleteUserDeniedReason {
  @override
  String toString() => 'Can only delete self.';
}
