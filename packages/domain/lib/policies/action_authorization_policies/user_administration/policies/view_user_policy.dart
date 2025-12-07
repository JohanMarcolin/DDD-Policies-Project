part of '../user_administration_policy.dart';

final class ViewUserPolicy extends UserAdministrationPolicy<ViewUserUnauthorizedReason> {
  ViewUserPolicy() : super(authorize: _authorizeViewUser);

  static ActionAuthorizationResult<ViewUserUnauthorizedReason> _authorizeViewUser(User initiator, User target) {
    switch (initiator.role) {
      case Role.analyst:
        return Authorized();
      case Role.admin:
      case Role.user:
        if (!target.isAnalyst) {
          return Authorized();
        } else {
          return Unauthorized(reason: CannotViewAnalyst());
        }
    }
  }
}

sealed class ViewUserUnauthorizedReason extends UserAdministrationUnauthorizedReason {}

final class CannotViewAnalyst extends ViewUserUnauthorizedReason {}
