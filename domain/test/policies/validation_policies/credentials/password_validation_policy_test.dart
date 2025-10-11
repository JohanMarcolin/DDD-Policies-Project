import 'package:domain/policies/policy_violation_exception.dart';
import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:domain/value_objects/password.dart';
import 'package:test/test.dart';

void main() {
  group('PasswordValidationPolicy', () {
    final policy = PasswordValidationPolicy();

    test('valid password passes', () {
      final password = Password('Abcdef1!');
      final result = policy.validate(password);
      expect(result, isA<Valid>());
      expect(policy.isValid(password), isTrue);
    });

    test('too short fails', () {
      final password = Password('A1!a');
      final result = policy.validate(password);
      expect(result, isA<Invalid>());
      expect((result as Invalid).reason, isA<PasswordTooShort>());
      expect(policy.isValid(password), isFalse);
    });

    test('too long fails', () {
      final password = Password('A' * 65 + '1!a');
      final result = policy.validate(password);
      expect(result, isA<Invalid>());
      expect((result as Invalid).reason, isA<PasswordTooLong>());
    });

    test('missing uppercase fails', () {
      final password = Password('abcdef1!');
      final result = policy.validate(password);
      expect(result, isA<Invalid>());
      expect((result as Invalid).reason, isA<PasswordMissingUppercase>());
    });

    test('missing lowercase fails', () {
      final password = Password('ABCDEF1!');
      final result = policy.validate(password);
      expect(result, isA<Invalid>());
      expect((result as Invalid).reason, isA<PasswordMissingLowercase>());
    });

    test('missing number fails', () {
      final password = Password('Abcdefg!');
      final result = policy.validate(password);
      expect(result, isA<Invalid>());
      expect((result as Invalid).reason, isA<PasswordMissingNumber>());
    });

    test('missing special character fails', () {
      final password = Password('Abcdefg1');
      final result = policy.validate(password);
      expect(result, isA<Invalid>());
      expect(
          (result as Invalid).reason, isA<PasswordMissingSpecialCharacter>());
    });

    test('enforce throws for invalid password', () {
      final password = Password('abc');
      expect(() => policy.enforce(password),
          throwsA(isA<PolicyViolationException>()));
    });

    test('enforce does not throw for valid password', () {
      final password = Password('Abcdef1!');
      expect(() => policy.enforce(password), returnsNormally);
    });

    test('generatePassword produces valid password', () {
      final policy = PasswordValidationPolicy();
      final generated = PasswordValidationPolicy.generatePassword(length: 12);
      expect(policy.isValid(generated), isTrue);
    });
  });
}
