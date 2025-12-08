import 'dart:math';
import 'package:domain/policies/value_validation_policies/value_validation_policy.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/password.dart';

part 'policies/user_email_validation_policy.dart';
part 'policies/user_password_validation_policy.dart';

/// Base class for user credential validation policies.
/// Determines if a credential value (e.g., email, password) is valid according to the implementing policy.
///
/// [TTValue]: type being validated (e.g., Email, Password)
/// [TReason]: reason type for invalid credentials (extends [UserCredentialInvalidReason])
abstract base class UserCredentialPolicy<TTValue, TReason extends UserCredentialInvalidReason>
    extends ValueValidationPolicy<TTValue, TReason> {
  /// Creates a user credential policy with the given validation logic.
  UserCredentialPolicy({required super.validate});
}

/// Base class for reasons why a user credential value was invalid.
///
/// Extend this class to define specific reasons for invalid user credentials in your policies.
sealed class UserCredentialInvalidReason extends ValueInvalidReason {}
