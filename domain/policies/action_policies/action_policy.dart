import '../../entities/user.dart';
import '../../value_objects/role.dart';
import '../policy_exception.dart';
import 'action_policy_permission.dart';

part 'user_administration/delete_user_policy.dart';
part 'user_administration/update_user_email_policy.dart';
part 'user_administration/update_user_password_policy.dart';
part 'user_administration/view_user_policy.dart';

abstract class ActionPolicy<TInitiator, TTarget> {
  const ActionPolicy();

  bool isPermitted(TInitiator initiator, TTarget target) =>
      evaluatePermission(initiator, target) is Granted;

  ActionPolicyPermission evaluatePermission(
      TInitiator initiator, TTarget target);
}

extension ActionPolicyEnforcement<TInitiator, TTarget>
    on ActionPolicy<TInitiator, TTarget> {
  TReturn enforce<TReturn>(
    TInitiator initiator,
    TTarget target, {
    required TReturn Function() onGranted,
  }) {
    final permission = evaluatePermission(initiator, target);
    return switch (permission) {
      Granted() => onGranted(),
      Denied(:final reason) => throw ActionPolicyException(reason),
    };
  }
}
