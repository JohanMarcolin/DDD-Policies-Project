import 'package:domain/policies/policy_violation_exception.dart';
import 'package:domain/policies/value_validation_policies/user_credentials/user_credential_policy.dart';
import 'package:domain/value_objects/email.dart';
import 'package:test/test.dart';

void main() {
  group('UserEmailValidationPolicy', () {
    final policy = UserEmailValidationPolicy();
    final validEmail = Email('user@example.com');
    final invalidEmail = Email('invalid-email');

    group('isValid', () {
      test('returns true for valid email', () {
        expect(policy.isValid(validEmail), isTrue);
      });

      test('returns false for invalid email', () {
        expect(policy.isValid(invalidEmail), isFalse);
      });
    });

    group('apply', () {
      test('returns onValid for valid email', () {
        final result = policy.apply(
          value: validEmail,
          onValid: () => 'valid',
          onInvalid: (reason) => 'invalid',
        );
        expect(result, equals('valid'));
      });

      test('returns onInvalid with EmailInvalidFormat for invalid email', () {
        final result = policy.apply(
          value: invalidEmail,
          onValid: () => 'valid',
          onInvalid: (reason) => reason,
        );
        expect(result, isA<EmailInvalidFormat>());
      });
    });

    group('enforce', () {
      test('returns normally for valid email', () {
        expect(() => policy.enforce(validEmail, onValid: () => 'valid'), returnsNormally);
      });

      test('throws for invalid email', () {
        expect(
          () => policy.enforce(invalidEmail, onValid: () => 'valid'),
          throwsA(
            predicate((e) => e is PolicyViolationException && e.reason is EmailInvalidFormat),
          ),
        );
      });
    });
  });
}
