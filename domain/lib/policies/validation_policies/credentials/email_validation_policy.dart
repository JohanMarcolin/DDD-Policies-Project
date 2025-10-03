part of '../validation_policy.dart';

final class EmailValidationPolicy
    extends ValidationPolicy<Email, EmailValidationPolicyResult> {
  const EmailValidationPolicy();

  static final RegExp _emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  bool _hasValidFormat(Email email) => _emailRegex.hasMatch(email.value);

  @override
  bool isValid(Email value) {
    return validate(value) is EmailValid;
  }

  @override
  EmailValidationPolicyResult validate(Email email) {
    if (!_hasValidFormat(email)) {
      return EmailInvalid(reason: EmailInvalidFormat());
    }
    return EmailValid();
  }

  @override
  void enforce(Email value) {
    switch (validate(value)) {
      case EmailValid():
        return;
      case EmailInvalid(:final reason):
        throw ValidationPolicyViolationException(reason);
    }
  }
}

sealed class EmailValidationPolicyResult {}

class EmailValid extends EmailValidationPolicyResult {}

class EmailInvalid extends EmailValidationPolicyResult {
  EmailInvalid({required this.reason});

  final EmailInvalidReason reason;
}

sealed class EmailInvalidReason {}

class EmailInvalidFormat implements EmailInvalidReason {}
