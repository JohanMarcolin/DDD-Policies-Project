part of '../user_administration_policy.dart';

/// Policy for determining if a [User] is authorized to view another [User].
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

/// Reasons why a [User] may be unauthorized to view another [User].
sealed class ViewUserUnauthorizedReason extends UserAdministrationUnauthorizedReason {}

final class CannotViewAnalyst extends ViewUserUnauthorizedReason {}
