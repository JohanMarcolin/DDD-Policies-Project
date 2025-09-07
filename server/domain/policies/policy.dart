import '../entities/user.dart';
import '../value_objects/role.dart';

part 'policy_compliance_result.dart';
part 'policy_non_compliant_reason.dart';
part 'user_administration/delete_user_policy.dart';
part 'user_administration/update_user_email_policy.dart';
part 'user_administration/update_user_password_policy.dart';
part 'user_administration/view_user_policy.dart';

sealed class Policy<TSubject, TObject> {
  const Policy(this.subject, this.object);

  final TSubject subject;
  final TObject object;

  bool isCompliant({required TSubject subject, required TObject object}) =>
      checkCompliance(subject: subject, object: object) is Compliant;

  PolicyComplianceResult checkCompliance(
      {required TSubject subject, required TObject object});
}
