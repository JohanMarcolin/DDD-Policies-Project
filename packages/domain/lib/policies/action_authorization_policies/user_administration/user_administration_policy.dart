import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_authorization_policies/action_authorization_policy.dart';
import 'package:domain/value_objects/role.dart';

part 'policies/delete_user_policy.dart';
part 'policies/update_user_email_policy.dart';
part 'policies/update_user_password_policy.dart';
part 'policies/view_user_policy.dart';

/// Base class for user administration policies.
/// Determines if a [User] is authorized to perform administrative actions on another [User].
///
/// [TReason]: reason type for unauthorized actions.
abstract base class UserAdministrationPolicy<TReason extends UserAdministrationUnauthorizedReason>
    extends ActionAuthorizationPolicy<User, User, TReason> {
  /// Creates a user administration policy with the given authorization logic.
  UserAdministrationPolicy({required super.authorize});
}

/// Base class for reasons why a user administration action was unauthorized.
///
/// Extend this class to define specific reasons for unauthorized user administration actions in your policies.
sealed class UserAdministrationUnauthorizedReason extends ActionUnauthorizedReason {}
