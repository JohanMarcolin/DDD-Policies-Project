import 'package:domain/policies/action_authorization_policies/user_administration/user_administration_policy.dart';
import 'package:domain/policies/value_validation_policies/user_credentials/user_credential_policy.dart';

class PolicyRegistry {
  static final viewUserPolicy = ViewUserPolicy();
  static final updateUserEmailPolicy = UpdateUserEmailPolicy();
  static final updateUserPasswordPolicy = UpdateUserPasswordPolicy();
  static final deleteUserPolicy = DeleteUserPolicy();
  static final userEmailValidationPolicy = UserEmailValidationPolicy();
  static final userPasswordValidationPolicy = UserPasswordValidationPolicy();
}