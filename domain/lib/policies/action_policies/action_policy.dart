import 'package:domain/policies/policy_violation_exception.dart';
import 'package:equatable/equatable.dart';

import '../../entities/user.dart';
import '../../../value_objects/role.dart';

part 'user_administration/delete_user_policy.dart';
part 'user_administration/update_user_email_policy.dart';
part 'user_administration/update_user_password_policy.dart';
part 'user_administration/view_user_policy.dart';

abstract base class ActionPolicy<TInitiator, TTarget> {
  const ActionPolicy({required this.authorize});

  final ActionPolicyResult Function(TInitiator, TTarget) authorize;

  bool isAuthorized(TInitiator initiator, TTarget target) =>
      authorize(initiator, target) is Authorized;

  dynamic requireAuthorization(
    TInitiator initiator,
    TTarget target, {
    required Function() onAuthorized,
  }) {
    final result = authorize(initiator, target);
    if (result is Authorized) {
      return onAuthorized();
    } else {
      throw ActionPolicyViolationException((result as Unauthorized).reason);
    }
  }
}

sealed class ActionPolicyResult extends Equatable {
  @override
  List<Object?> get props => [];

  bool get isAuthorized => this is Authorized;
}

class Authorized extends ActionPolicyResult {}

class Unauthorized<TReason> extends ActionPolicyResult {
  Unauthorized({required this.reason});

  final TReason reason;
}
