part of '../validation_policy.dart';

final class EmailValidationPolicy extends ValidationPolicy<Email> {
  EmailValidationPolicy() : super(validate: _validateEmail);

  static final RegExp _emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  static ValidationPolicyResult _validateEmail(Email email) {
    if (_emailRegex.hasMatch(email.value)) {
      return Valid();
    }
    return Invalid(reason: EmailInvalidFormat());
  }
}

sealed class EmailInvalidReason {
  @override
  String toString() => runtimeType.toString();
}

class EmailInvalidFormat implements EmailInvalidReason {}
