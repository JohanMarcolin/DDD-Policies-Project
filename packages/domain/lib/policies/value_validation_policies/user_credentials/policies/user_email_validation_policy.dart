part of '../user_credential_policy.dart';

final class UserEmailValidationPolicy extends UserCredentialPolicy<Email, EmailInvalidReason> {
  UserEmailValidationPolicy() : super(validate: _validateEmail);

  static final RegExp _emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  static ValidationResult<EmailInvalidReason> _validateEmail(Email email) {
    if (_emailRegex.hasMatch(email.value)) {
      return Valid();
    }
    return Invalid(reason: EmailInvalidFormat());
  }
}

sealed class EmailInvalidReason extends UserCredentialInvalidReason {}

final class EmailInvalidFormat extends EmailInvalidReason {}
