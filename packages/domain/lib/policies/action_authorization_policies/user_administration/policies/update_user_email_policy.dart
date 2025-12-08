part of '../user_administration_policy.dart';

/// Policy for determining if a [User] is authorized to update their own email or another [User]'s email.
final class UpdateUserEmailPolicy extends UserAdministrationPolicy<UpdateUserEmailUnauthorizedReason> {
  UpdateUserEmailPolicy() : super(authorize: _authorizeUpdateUserEmail);

  static ActionAuthorizationResult<UpdateUserEmailUnauthorizedReason> _authorizeUpdateUserEmail(
      User initiator, User target) {
    final isUpdatingOwnEmail = initiator.isSameAs(target);

    switch (initiator.role) {
      case Role.analyst:
        return Authorized();
      case Role.admin:
        if (!target.isAnalyst) {
          return Authorized();
        } else {
          return Unauthorized(reason: CannotUpdateEmailOnAnalyst());
        }
      case Role.user:
        if (isUpdatingOwnEmail) {
          return Authorized();
        } else {
          return Unauthorized(reason: CanOnlyUpdateEmailOnSelf());
        }
    }
  }
}

sealed class UpdateUserEmailUnauthorizedReason extends UserAdministrationUnauthorizedReason {}

final class CannotUpdateEmailOnAnalyst extends UpdateUserEmailUnauthorizedReason {}

final class CanOnlyUpdateEmailOnSelf extends UpdateUserEmailUnauthorizedReason {}
