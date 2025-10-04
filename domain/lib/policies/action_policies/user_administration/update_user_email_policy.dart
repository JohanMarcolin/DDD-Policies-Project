part of '../action_policy.dart';

final class UpdateUserEmailPolicy extends ActionPolicy<User, User> {
  const UpdateUserEmailPolicy() : super(authorize: _authorizeUpdateUserEmail);

  static ActionPolicyResult _authorizeUpdateUserEmail(
      User initiator, User target) {
    final isModifyingSelf = initiator.isSameAs(target);

    switch (initiator.role) {
      case Role.analyst:
        return Authorized();
      case Role.admin:
        if (!target.isAnalyst()) {
          return Authorized();
        } else {
          return Unauthorized(reason: CannotUpdateEmailOnAnalyst());
        }
      case Role.user:
        if (isModifyingSelf) {
          return Authorized();
        } else {
          return Unauthorized(reason: CanOnlyUpdateEmailOnSelf());
        }
    }
  }
}

sealed class UpdateUserEmailUnauthorizedReason {}

class CannotUpdateEmailOnAnalyst implements UpdateUserEmailUnauthorizedReason {}

class CanOnlyUpdateEmailOnSelf implements UpdateUserEmailUnauthorizedReason {}
