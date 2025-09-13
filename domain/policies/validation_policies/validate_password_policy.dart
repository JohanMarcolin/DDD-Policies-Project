part of 'validation_policy.dart';

class ValidatePasswordPolicy extends ValidationPolicy<Password> {
  static const minLength = 8;
  static const maxLength = 64;
  static const includeUppercase = true;
  static const includeLowercase = true;
  static const includeNumbers = true;
  static const includeSpecialCharacters = true;

  ValidationPolicyResult evaluateValidity(Password password) {
    final value = password.value;

    if (value.length < minLength) {
      return Invalid(reason: PasswordTooShort());
    }
    if (value.length > maxLength) {
      return Invalid(reason: PasswordTooLong());
    }
    if (includeUppercase && !value.contains(RegExp(r'[A-Z]'))) {
      return Invalid(reason: PasswordMissingUppercase());
    }
    if (includeLowercase && !value.contains(RegExp(r'[a-z]'))) {
      return Invalid(reason: PasswordMissingLowercase());
    }
    if (includeNumbers && !value.contains(RegExp(r'[0-9]'))) {
      return Invalid(reason: PasswordMissingNumber());
    }
    if (includeSpecialCharacters &&
        !value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      return Invalid(reason: PasswordMissingSpecialCharacter());
    }
    return Valid();
  }

  Password generatePassword({
    int length = 10,
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

    while (true) {
      final candidate = Password(
        List.generate(length, (_) => chars[random.nextInt(chars.length)])
            .join(),
      );
      if (ValidatePasswordPolicy().evaluateValidity(candidate) is Valid) {
        return candidate;
      }
    }
  }
}

sealed class PasswordInvalidReason {}

class PasswordTooShort implements PasswordInvalidReason {
  @override
  String toString() => 'Password is too short.';
}

class PasswordTooLong implements PasswordInvalidReason {
  @override
  String toString() => 'Password is too long.';
}

class PasswordMissingUppercase implements PasswordInvalidReason {
  @override
  String toString() => 'Password is missing an uppercase letter.';
}

class PasswordMissingLowercase implements PasswordInvalidReason {
  @override
  String toString() => 'Password is missing a lowercase letter.';
}

class PasswordMissingNumber implements PasswordInvalidReason {
  @override
  String toString() => 'Password is missing a number.';
}

class PasswordMissingSpecialCharacter implements PasswordInvalidReason {
  @override
  String toString() => 'Password is missing a special character.';
}
