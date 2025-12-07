part of '../user_administration_policy.dart';

final class DeleteUserPolicy extends UserAdministrationPolicy<DeleteUserUnauthorizedReason> {
  DeleteUserPolicy() : super(authorize: _authorizeDeleteUser);

  static ActionAuthorizationResult<DeleteUserUnauthorizedReason> _authorizeDeleteUser(User initiator, User target) {
    final isDeletingSelf = initiator.isSameAs(target);

    switch (initiator.role) {
      case Role.analyst:
        if (!isDeletingSelf) {
          return Authorized();
        } else {
          return Unauthorized(reason: CannotDeleteSelf());
        }
      case Role.admin:
        if (!target.isAnalyst) {
          return Authorized();
        } else {
          return Unauthorized(reason: CannotDeleteAnalyst());
        }
      case Role.user:
        if (isDeletingSelf) {
          return Authorized();
        } else {
          return Unauthorized(reason: CanOnlyDeleteSelf());
        }
    }
  }
}

sealed class DeleteUserUnauthorizedReason {}

class CannotDeleteSelf implements DeleteUserUnauthorizedReason {}

class CannotDeleteAnalyst implements DeleteUserUnauthorizedReason {}

class CanOnlyDeleteSelf implements DeleteUserUnauthorizedReason {}
