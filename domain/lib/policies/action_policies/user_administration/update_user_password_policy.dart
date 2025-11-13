part of '../action_policy.dart';

final class UpdateUserPasswordPolicy extends ActionPolicy<User, User> {
  const UpdateUserPasswordPolicy() : super(authorize: _authorizeUpdateUserPassword);

  static ActionPolicyResult _authorizeUpdateUserPassword(User initiator, User target) {
    final isModifyingSelf = initiator.isSameAs(target);

    switch (initiator.role) {
      case Role.analyst:
        return Authorized();
      case Role.admin:
        if (!target.isAnalyst) {
          return Authorized();
        } else {
          return Unauthorized(reason: CannotUpdatePasswordOnAnalyst());
        }
      case Role.user:
        if (isModifyingSelf) {
          return Authorized();
        } else {
          return Unauthorized(reason: CanOnlyUpdatePasswordOnSelf());
        }
    }
  }
}

sealed class UpdateUserPasswordUnauthorizedReason {}

class CannotUpdatePasswordOnAnalyst implements UpdateUserPasswordUnauthorizedReason {}

class CanOnlyUpdatePasswordOnSelf implements UpdateUserPasswordUnauthorizedReason {}
