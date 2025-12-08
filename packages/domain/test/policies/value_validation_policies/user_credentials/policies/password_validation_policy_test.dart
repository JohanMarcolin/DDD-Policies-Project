import 'package:domain/policies/policy_violation_exception.dart';
import 'package:domain/policies/value_validation_policies/user_credentials/user_credential_policy.dart';
import 'package:domain/value_objects/password.dart';
import 'package:test/test.dart';

void main() {
  group('UserPasswordValidationPolicy', () {
    final policy = UserPasswordValidationPolicy();
    final validPassword = Password('Abcdef1!');
    final shortPassword = Password('A1!a');
    final longPassword = Password('A' * 65 + '1!a');
    final noUppercase = Password('abcdef1!');
    final noLowercase = Password('ABCDEF1!');
    final noNumber = Password('Abcdefg!');
    final noSpecial = Password('Abcdefg1');

    group('isValid', () {
      test('returns true for valid password', () {
        expect(policy.isValid(validPassword), isTrue);
      });

      test('returns false for too short', () {
        expect(policy.isValid(shortPassword), isFalse);
      });

      test('returns false for too long', () {
        expect(policy.isValid(longPassword), isFalse);
      });

      test('returns false for missing uppercase', () {
        expect(policy.isValid(noUppercase), isFalse);
      });

      test('returns false for missing lowercase', () {
        expect(policy.isValid(noLowercase), isFalse);
      });

      test('returns false for missing number', () {
        expect(policy.isValid(noNumber), isFalse);
      });

      test('returns false for missing special character', () {
        expect(policy.isValid(noSpecial), isFalse);
      });
    });

    group('apply', () {
      test('returns onValid for valid password', () {
        final result = policy.apply(
          value: validPassword,
          onValid: () => 'valid',
          onInvalid: (reason) => 'invalid',
        );
        expect(result, equals('valid'));
      });

      test('returns onInvalid with PasswordTooShort', () {
        final result = policy.apply(
          value: shortPassword,
          onValid: () => 'valid',
          onInvalid: (reason) => reason,
        );
        expect(result, isA<PasswordTooShort>());
      });

      test('returns onInvalid with PasswordTooLong', () {
        final result = policy.apply(
          value: longPassword,
          onValid: () => 'valid',
          onInvalid: (reason) => reason,
        );
        expect(result, isA<PasswordTooLong>());
      });

      test('returns onInvalid with PasswordMissingUppercase', () {
        final result = policy.apply(
          value: noUppercase,
          onValid: () => 'valid',
          onInvalid: (reason) => reason,
        );
        expect(result, isA<PasswordMissingUppercase>());
      });

      test('returns onInvalid with PasswordMissingLowercase', () {
        final result = policy.apply(
          value: noLowercase,
          onValid: () => 'valid',
          onInvalid: (reason) => reason,
        );
        expect(result, isA<PasswordMissingLowercase>());
      });

      test('returns onInvalid with PasswordMissingNumber', () {
        final result = policy.apply(
          value: noNumber,
          onValid: () => 'valid',
          onInvalid: (reason) => reason,
        );
        expect(result, isA<PasswordMissingNumber>());
      });

      test('returns onInvalid with PasswordMissingSpecialCharacter', () {
        final result = policy.apply(
          value: noSpecial,
          onValid: () => 'valid',
          onInvalid: (reason) => reason,
        );
        expect(result, isA<PasswordMissingSpecialCharacter>());
      });
    });

    group('enforce', () {
      test('returns normally for valid password', () {
        expect(() => policy.enforce(validPassword, onValid: () => 'valid'), returnsNormally);
      });

      test('throws for too short', () {
        expect(
          () => policy.enforce(shortPassword, onValid: () => 'valid'),
          throwsA(
            predicate((e) => e is PolicyViolationException && e.reason is PasswordTooShort),
          ),
        );
      });

      test('throws for too long', () {
        expect(
          () => policy.enforce(longPassword, onValid: () => 'valid'),
          throwsA(
            predicate((e) => e is PolicyViolationException && e.reason is PasswordTooLong),
          ),
        );
      });

      test('throws for missing uppercase', () {
        expect(
          () => policy.enforce(noUppercase, onValid: () => 'valid'),
          throwsA(
            predicate((e) => e is PolicyViolationException && e.reason is PasswordMissingUppercase),
          ),
        );
      });

      test('throws for missing lowercase', () {
        expect(
          () => policy.enforce(noLowercase, onValid: () => 'valid'),
          throwsA(
            predicate((e) => e is PolicyViolationException && e.reason is PasswordMissingLowercase),
          ),
        );
      });

      test('throws for missing number', () {
        expect(
          () => policy.enforce(noNumber, onValid: () => 'valid'),
          throwsA(
            predicate((e) => e is PolicyViolationException && e.reason is PasswordMissingNumber),
          ),
        );
      });

      test('throws for missing special character', () {
        expect(
          () => policy.enforce(noSpecial, onValid: () => 'valid'),
          throwsA(
            predicate((e) => e is PolicyViolationException && e.reason is PasswordMissingSpecialCharacter),
          ),
        );
      });
    });

    group('generateRandomPassword', () {
      test('produces valid password', () {
        final generated = policy.generateRandomPassword(length: 12);
        expect(policy.isValid(generated), isTrue);
      });
    });
  });
}
