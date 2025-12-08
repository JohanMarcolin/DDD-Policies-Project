import 'dart:math';
import 'package:domain/policies/value_validation_policies/value_validation_policy.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/password.dart';

part 'policies/user_email_validation_policy.dart';
part 'policies/user_password_validation_policy.dart';

abstract base class UserCredentialPolicy<TTValue, TReason extends UserCredentialInvalidReason>
    extends ValueValidationPolicy<TTValue, TReason> {
  UserCredentialPolicy({required super.validate});
}

sealed class UserCredentialInvalidReason extends ValueInvalidReason {}
