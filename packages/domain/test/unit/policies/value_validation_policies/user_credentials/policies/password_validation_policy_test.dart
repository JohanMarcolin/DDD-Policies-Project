import 'package:domain/policies/policy_violation_exception.dart';
import 'package:domain/policies/value_validation_policies/user_credentials/user_credential_policy.dart';
import 'package:test/test.dart';
import 'package:test_utils/mocks/mock_user_credentials.dart';

void main() {
  group('UserPasswordValidationPolicy', () {
    final policy = UserPasswordValidationPolicy();

    group('isValid', () {
      test('returns true for valid password', () {
        expect(policy.isValid(mockValidPassword), isTrue);
      });

      test('returns false for too short', () {
        expect(policy.isValid(mockTooShortPassword), isFalse);
      });

      test('returns false for too long', () {
        expect(policy.isValid(mockTooLongPassword), isFalse);
      });

      test('returns false for missing uppercase', () {
        expect(policy.isValid(mockMissingUppercasePassword), isFalse);
      });

      test('returns false for missing lowercase', () {
        expect(policy.isValid(mockMissingLowercasePassword), isFalse);
      });

      test('returns false for missing number', () {
        expect(policy.isValid(mockMissingNumberPassword), isFalse);
      });

      test('returns false for missing special character', () {
        expect(policy.isValid(mockMissingSpecialCharPassword), isFalse);
      });
    });

    group('apply', () {
      test('returns onValid for valid password', () {
        final result = policy.apply(
          value: mockValidPassword,
          onValid: () => 'valid',
          onInvalid: (reason) => 'invalid',
        );
        expect(result, equals('valid'));
      });

      test('returns onInvalid with PasswordTooShort', () {
        final result = policy.apply(
          value: mockTooShortPassword,
          onValid: () => 'valid',
          onInvalid: (reason) => reason,
        );
        expect(result, isA<PasswordTooShort>());
      });

      test('returns onInvalid with PasswordTooLong', () {
        final result = policy.apply(
          value: mockTooLongPassword,
          onValid: () => 'valid',
          onInvalid: (reason) => reason,
        );
        expect(result, isA<PasswordTooLong>());
      });

      test('returns onInvalid with PasswordMissingUppercase', () {
        final result = policy.apply(
          value: mockMissingUppercasePassword,
          onValid: () => 'valid',
          onInvalid: (reason) => reason,
        );
        expect(result, isA<PasswordMissingUppercase>());
      });

      test('returns onInvalid with PasswordMissingLowercase', () {
        final result = policy.apply(
          value: mockMissingLowercasePassword,
          onValid: () => 'valid',
          onInvalid: (reason) => reason,
        );
        expect(result, isA<PasswordMissingLowercase>());
      });

      test('returns onInvalid with PasswordMissingNumber', () {
        final result = policy.apply(
          value: mockMissingNumberPassword,
          onValid: () => 'valid',
          onInvalid: (reason) => reason,
        );
        expect(result, isA<PasswordMissingNumber>());
      });

      test('returns onInvalid with PasswordMissingSpecialChar', () {
        final result = policy.apply(
          value: mockMissingSpecialCharPassword,
          onValid: () => 'valid',
          onInvalid: (reason) => reason,
        );
        expect(result, isA<PasswordMissingSpecialCharacter>());
      });
    });

    group('enforce', () {
      test('returns normally for valid password', () {
        expect(() => policy.enforce(mockValidPassword, onValid: () {}), returnsNormally);
      });
      test('throws for too short', () {
        expect(() => policy.enforce(mockTooShortPassword, onValid: () {}), throwsA(isA<PolicyViolationException>()));
      });
      test('throws for too long', () {
        expect(() => policy.enforce(mockTooLongPassword, onValid: () {}), throwsA(isA<PolicyViolationException>()));
      });
      test('throws for missing uppercase', () {
        expect(() => policy.enforce(mockMissingUppercasePassword, onValid: () {}),
            throwsA(isA<PolicyViolationException>()));
      });
      test('throws for missing lowercase', () {
        expect(() => policy.enforce(mockMissingLowercasePassword, onValid: () {}),
            throwsA(isA<PolicyViolationException>()));
      });
      test('throws for missing number', () {
        expect(
            () => policy.enforce(mockMissingNumberPassword, onValid: () {}), throwsA(isA<PolicyViolationException>()));
      });
      test('throws for missing special character', () {
        expect(() => policy.enforce(mockMissingSpecialCharPassword, onValid: () {}),
            throwsA(isA<PolicyViolationException>()));
      });
    });
  });
}
