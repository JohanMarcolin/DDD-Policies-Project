part of '../user_administration_policy.dart';

/// Policy for determining if a [User] is authorized to update their own password or another [User]'s password.
final class UpdateUserPasswordPolicy extends UserAdministrationPolicy<UpdateUserPasswordUnauthorizedReason> {
  UpdateUserPasswordPolicy() : super(authorize: _authorizeUpdateUserPassword);

  static ActionAuthorizationResult<UpdateUserPasswordUnauthorizedReason> _authorizeUpdateUserPassword(
      User initiator, User target) {
    final isUpdatingOwnPassword = initiator.isSameAs(target);

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
        if (isUpdatingOwnPassword) {
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
