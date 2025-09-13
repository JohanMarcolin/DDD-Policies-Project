import 'validation_result.dart';

class Email {
  Email(this.value);

  final String value;

  static final RegExp _emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  bool get isValid => validate() is ValidationSuccess;
  bool get _hasValidFormat => _emailRegex.hasMatch(value);

  ValidationResult validate() {
    if (!_hasValidFormat) {
      return ValidationError(reason: InvalidEmailFormat());
    }
    return const ValidationSuccess();
  }
}

extension ValidationEnforcement on Email {
  void enforceValidation() {
    final result = validate();
    switch (result) {
      case ValidationSuccess():
        return;
      case ValidationError(:final reason):
        throw EmailValidationErrorException(reason);
    }
  }
}

class EmailValidationErrorException extends ValidationErrorException {
  EmailValidationErrorException(super.reason);

  @override
  String toString() => 'EmailValidationException: $reason';
}

class InvalidEmailFormat extends ValidationErrorReason {
  const InvalidEmailFormat();

  @override
  String toString() => 'Email format is invalid';
}
