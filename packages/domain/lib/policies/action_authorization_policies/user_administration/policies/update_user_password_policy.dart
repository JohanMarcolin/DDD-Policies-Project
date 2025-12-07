part of '../user_administration_policy.dart';

final class UpdateUserPasswordPolicy extends UserAdministrationPolicy<UpdateUserPasswordUnauthorizedReason> {
  UpdateUserPasswordPolicy() : super(authorize: _authorizeUpdateUserPassword);

  static ActionAuthorizationResult<UpdateUserPasswordUnauthorizedReason> _authorizeUpdateUserPassword(
      User initiator, User target) {
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

sealed class UpdateUserPasswordUnauthorizedReason extends UserAdministrationUnauthorizedReason {}

final class CannotUpdatePasswordOnAnalyst extends UpdateUserPasswordUnauthorizedReason {}

final class CanOnlyUpdatePasswordOnSelf extends UpdateUserPasswordUnauthorizedReason {}
