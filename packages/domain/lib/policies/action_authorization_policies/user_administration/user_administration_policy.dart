import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_authorization_policies/action_authorization_policy.dart';
import 'package:domain/value_objects/role.dart';

part 'policies/delete_user_policy.dart';
part 'policies/update_user_email_policy.dart';
part 'policies/update_user_password_policy.dart';
part 'policies/view_user_policy.dart';

abstract base class UserAdministrationPolicy<TUnauthorizedReason>
    extends ActionAuthorizationPolicy<User, User, TUnauthorizedReason> {
  UserAdministrationPolicy({required super.authorize});
}
