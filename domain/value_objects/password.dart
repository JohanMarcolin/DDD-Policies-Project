import 'dart:math';
import 'validation_result.dart';

class Password {
  Password(this.value);

  final String value;

  static const minLength = 8;
  static const maxLength = 64;
  static const includeUppercase = true;
  static const includeLowercase = true;
  static const includeNumbers = true;
  static const includeSpecialCharacters = true;

  bool get isValid => validate() is ValidationSuccess;

  bool get _isTooShort => value.length < minLength;
  bool get _isTooLong => value.length > maxLength;
  bool get _hasUppercase => value.contains(RegExp(r'[A-Z]'));
  bool get _hasLowercase => value.contains(RegExp(r'[a-z]'));
  bool get _hasNumber => value.contains(RegExp(r'[0-9]'));
  bool get _hasSpecialCharacter =>
      value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));

  ValidationResult validate() {
    if (_isTooShort) {
      return ValidationError(reason: PasswordTooShort());
    }
    if (_isTooLong) {
      return ValidationError(reason: PasswordTooLong());
    }
    if (includeUppercase && !_hasUppercase) {
      return ValidationError(reason: PasswordMissingUppercase());
    }
    if (includeLowercase && !_hasLowercase) {
      return ValidationError(reason: PasswordMissingLowercase());
    }
    if (includeNumbers && !_hasNumber) {
      return ValidationError(reason: PasswordMissingNumber());
    }
    if (includeSpecialCharacters && !_hasSpecialCharacter) {
      return ValidationError(reason: PasswordMissingSpecialCharacter());
    }
    return const ValidationSuccess();
  }

  static Password generate({
    int length = 16,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeNumbers = true,
    bool includeSpecialCharacters = true,
  }) {
    const upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lower = 'abcdefghijklmnopqrstuvwxyz';
    const numbers = '0123456789';
    const special = '!@#\$%^&*(),.?":{}|<>';
    String chars = '';
    if (includeUppercase) chars += upper;
    if (includeLowercase) chars += lower;
    if (includeNumbers) chars += numbers;
    if (includeSpecialCharacters) chars += special;
    if (chars.isEmpty) chars = lower;
    final random = Random.secure();
    return Password(
        List.generate(length, (_) => chars[random.nextInt(chars.length)])
            .join());
  }
}

extension ValidationEnforcement on Password {
  void enforceValidation() {
    final result = validate();
    switch (result) {
      case ValidationSuccess():
        () => {};
      case ValidationError(:final reason):
        () => throw PasswordValidationErrorException(reason);
    }
  }
}

class PasswordValidationErrorException extends ValidationErrorException {
  PasswordValidationErrorException(super.reason);

  @override
  String toString() => 'PasswordValidationException: $reason';
}

class PasswordTooShort extends ValidationErrorReason {
  @override
  String toString() => 'Password is too short';
}

class PasswordTooLong extends ValidationErrorReason {
  @override
  String toString() => 'Password is too long';
}

class PasswordMissingUppercase extends ValidationErrorReason {
  @override
  String toString() => 'Password is missing an uppercase letter';
}

class PasswordMissingLowercase extends ValidationErrorReason {
  @override
  String toString() => 'Password is missing a lowercase letter';
}

class PasswordMissingNumber extends ValidationErrorReason {
  @override
  String toString() => 'Password is missing a number';
}

class PasswordMissingSpecialCharacter extends ValidationErrorReason {
  @override
  String toString() => 'Password is missing a special character';
}
