import 'package:domain/policies/action_authorization_policies/user_administration/user_administration_policy.dart';
import 'package:domain/policies/value_validation_policies/user_credentials/user_credential_policy.dart';

/// A registry for accessing policies used in the application.
class PolicyRegistry {
  static final deleteUserPolicy = DeleteUserPolicy();
  static final updateUserEmailPolicy = UpdateUserEmailPolicy();
  static final updateUserPasswordPolicy = UpdateUserPasswordPolicy();
  static final userEmailValidationPolicy = UserEmailValidationPolicy();
  static final userPasswordValidationPolicy = UserPasswordValidationPolicy();
  static final viewUserPolicy = ViewUserPolicy();
}
