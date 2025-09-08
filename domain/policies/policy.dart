import '../entities/user.dart';
import '../value_objects/role.dart';

part 'policy_compliance_result.dart';
part 'policy_violation_reason.dart';
part 'user_administration/delete_user_policy.dart';
part 'user_administration/update_user_email_policy.dart';
part 'user_administration/update_user_password_policy.dart';
part 'user_administration/view_user_policy.dart';

sealed class Policy<TRequester, TTarget> {
  const Policy();

  bool isCompliant({required TRequester requester, required TTarget target}) =>
      checkCompliance(requester: requester, target: target) is Compliant;

  PolicyComplianceResult checkCompliance(
      {required TRequester requester, required TTarget target});
}
