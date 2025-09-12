import '../entities/user.dart';
import '../value_objects/role.dart';

part 'policy_permission.dart';
part 'policy_permission_denied_reason.dart';
part 'policy_permission_denied_exception.dart';

part 'user_administration/delete_user_policy.dart';
part 'user_administration/update_user_email_policy.dart';
part 'user_administration/update_user_password_policy.dart';
part 'user_administration/view_user_policy.dart';

sealed class Policy<TInitiator, TTarget> {
  const Policy();

  bool isPermitted(TInitiator initiator, TTarget target) =>
      evaluatePermission(initiator, target) is PermissionGranted;

  PolicyPermission evaluatePermission(TInitiator initiator, TTarget target);
}

extension PolicyEnforcement<TInitiator, TTarget>
    on Policy<TInitiator, TTarget> {
  TReturn enforce<TReturn>(
    TInitiator initiator,
    TTarget target, {
    required TReturn Function() onPermissionGranted,
  }) {
    final permission = evaluatePermission(initiator, target);
    return switch (permission) {
      PermissionGranted() => onPermissionGranted(),
      PermissionDenied(:final reason) =>
        throw PolicyPermissionDeniedException(reason),
    };
  }
}
