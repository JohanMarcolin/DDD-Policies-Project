import 'package:domain/policies/policy_violation_exception.dart';

import '../../entities/user.dart';
import '../../../value_objects/role.dart';

part 'user_administration/delete_user_policy.dart';
part 'user_administration/update_user_email_policy.dart';
part 'user_administration/update_user_password_policy.dart';
part 'user_administration/view_user_policy.dart';

abstract base class ActionPolicy<TInitiator, TTarget, TPermission> {
  const ActionPolicy();

  bool isAuthorized(TInitiator initiator, TTarget target);

  TPermission authorize(TInitiator initiator, TTarget target);

  dynamic requireAuthorization(
    TInitiator initiator,
    TTarget target, {
    required Function() onAuthorized,
  });
}
