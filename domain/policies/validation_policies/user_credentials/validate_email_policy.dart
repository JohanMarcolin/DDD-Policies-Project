part of '../validation_policy.dart';

class ValidateEmailPolicy extends ValidationPolicy<Email> {
  const ValidateEmailPolicy();

  static final RegExp _emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  bool isValid(Email email) => evaluateValidity(email) is ValidationSuccess;
  bool _hasValidFormat(Email email) => _emailRegex.hasMatch(email.value);

  @override
  ValidationPolicyResult evaluateValidity(Email email) {
    if (!_hasValidFormat(email)) {
      return Invalid(reason: EmailInvalidFormat());
    }
    return Valid();
  }
}

sealed class EmailInvalidReason {}

class EmailInvalidFormat implements EmailInvalidReason {
  @override
  String toString() => 'Email format is invalid.';
}
