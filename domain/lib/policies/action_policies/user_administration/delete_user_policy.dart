part of '../action_policy.dart';

final class DeleteUserPolicy extends ActionPolicy<User, User, DeleteUserPermission> {
  const DeleteUserPolicy();

  @override
  bool isAuthorized(User initiator, User target) =>
      authorize(initiator, target) is DeleteUserGranted;

  @override
  DeleteUserPermission authorize(User initiator, User target) {
    final isDeletingSelf = initiator.isSameAs(target);

    switch (initiator.role) {
      case Role.analyst:
        if (!isDeletingSelf) {
          return DeleteUserGranted();
        } else {
          return DeleteUserDenied(reason: CanOnlyDeleteSelf());
        }
      case Role.admin:
        if (!target.isAnalyst()) {
          return DeleteUserGranted();
        } else {
          return DeleteUserDenied(reason: CannotDeleteAnalyst());
        }
      case Role.user:
        if (isDeletingSelf) {
          return DeleteUserGranted();
        } else {
          return DeleteUserDenied(reason: CanOnlyDeleteSelf());
        }
    }
  }

  @override
  requireAuthorization(User initiator, User target,
      {required Function() onAuthorized}) {
    switch (authorize(initiator, target)) {
      case DeleteUserGranted():
        return onAuthorized();
      case DeleteUserDenied(:final reason):
        throw ActionPolicyViolationException(reason);
    }
  }
}

sealed class DeleteUserPermission {}

class DeleteUserGranted extends DeleteUserPermission {}

class DeleteUserDenied extends DeleteUserPermission {
  DeleteUserDenied({required this.reason});

  final DeleteUserDeniedReason reason;
}

sealed class DeleteUserDeniedReason {}

class CannotDeleteSelf implements DeleteUserDeniedReason {}

class CannotDeleteAnalyst implements DeleteUserDeniedReason {}

class CanOnlyDeleteSelf implements DeleteUserDeniedReason {}
