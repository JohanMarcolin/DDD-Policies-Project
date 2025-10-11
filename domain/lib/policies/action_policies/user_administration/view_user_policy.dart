part of '../action_policy.dart';

final class ViewUserPolicy extends ActionPolicy<User, User> {
  const ViewUserPolicy() : super(authorize: _authorizeViewUser);

  static ActionPolicyResult _authorizeViewUser(User initiator, User target) {
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

sealed class ViewUserUnauthorizedReason {}

class CannotViewAnalyst implements ViewUserUnauthorizedReason {}
