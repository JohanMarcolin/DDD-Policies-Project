import 'package:domain/policies/policy_violation_exception.dart';
import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:domain/value_objects/email.dart';
import 'package:test/test.dart';

void main() {
  group('EmailValidationPolicy', () {
    final policy = EmailValidationPolicy();

    test('valid email passes', () {
      final email = Email('user@example.com');
      final result = policy.validate(email);
      expect(result, isA<EmailValid>());
      expect(policy.isValid(email), isTrue);
    });

    test('invalid email fails', () {
      final email = Email('invalid-email');
      final result = policy.validate(email);
      expect(result, isA<EmailInvalid>());
      expect((result as EmailInvalid).reason, isA<EmailInvalidFormat>());
      expect(policy.isValid(email), isFalse);
    });

    test('enforce throws for invalid email format', () {
      final email = Email('bad');
      expect(
        () => policy.enforce(email),
        throwsA(
          predicate((e) =>
              e is PolicyViolationException && e.reason is EmailInvalidFormat),
        ),
      );
    });

    test('enforce does not throw for valid email', () {
      final email = Email('good@example.com');
      expect(() => policy.enforce(email), returnsNormally);
    });
  });
}
