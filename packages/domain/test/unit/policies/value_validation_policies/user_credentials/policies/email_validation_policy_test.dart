import 'package:domain/policies/policy_violation_exception.dart';
import 'package:domain/policies/value_validation_policies/user_credentials/user_credential_policy.dart';
import 'package:test/test.dart';
import 'package:test_utils/mocks/mock_user_credentials.dart';

void main() {
  group('UserEmailValidationPolicy', () {
    final policy = UserEmailValidationPolicy();

    group('isValid', () {
      test('returns true for valid email', () {
        expect(policy.isValid(mockValidEmail), isTrue);
      });

      test('returns false for invalid email', () {
        expect(policy.isValid(mockInvalidEmail), isFalse);
      });
    });

    group('apply', () {
      test('returns onValid for valid email', () {
        final result = policy.apply(
          value: mockValidEmail,
          onValid: () => 'valid',
          onInvalid: (reason) => 'invalid',
        );
        expect(result, equals('valid'));
      });

      test('returns onInvalid with EmailInvalidFormat for invalid email', () {
        final result = policy.apply(
          value: mockInvalidEmail,
          onValid: () => 'valid',
          onInvalid: (reason) => reason,
        );
        expect(result, isA<EmailInvalidFormat>());
      });
    });

    group('enforce', () {
      test('returns normally for valid email', () {
        expect(() => policy.enforce(mockValidEmail, onValid: () => 'valid'), returnsNormally);
      });

      test('throws for invalid email', () {
        expect(
          () => policy.enforce(mockInvalidEmail, onValid: () => 'valid'),
          throwsA(
            predicate((e) => e is PolicyViolationException && e.reason is EmailInvalidFormat),
          ),
        );
      });
    });
  });
}
