part of '../action_policy.dart';

enum UpdateUserEmailPolicyDenialReason {
  cannotModifyAnalyst,
  canOnlyModifySelf,
}

class UpdateUserEmailPolicy extends ActionPolicy<User, User> {
  const UpdateUserEmailPolicy();

  @override
  ActionPolicyPermission evaluatePermission(User initiator, User target) {
    final isModifyingSelf = initiator.isSameAs(target);

    switch (initiator.role) {
      case Role.analyst:
        return Granted();
      case Role.admin:
        if (!target.isAnalyst()) {
          return Granted();
        } else {
          return Denied(reason: CannotUpdateEmailOnAnalyst());
        }
      case Role.user:
        if (isModifyingSelf) {
          return Granted();
        } else {
          return Denied(reason: CanOnlyUpdateEmailOnSelf());
        }
    }
  }
}

sealed class UpdateUserEmailDeniedReason {}

class CannotUpdateEmailOnAnalyst implements UpdateUserEmailDeniedReason {
  @override
  String toString() => 'Cannot update email on analyst.';
}

class CanOnlyUpdateEmailOnSelf implements UpdateUserEmailDeniedReason {
  @override
  String toString() => 'Can only update email on self.';
}
