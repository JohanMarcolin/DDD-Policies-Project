import 'package:domain/policies/policy_violation_exception.dart';
import 'package:test/test.dart';
import '../../utils/policies/value_validation_policies/dummy_value_validation_policy.dart';

void main() {
  group('ValueValidationPolicy', () {
    final alwaysValidPolicy = DummyAlwaysValidValidationPolicy();
    final alwaysInvalidPolicy = DummyAlwaysInvalidValidationPolicy();

    group('isValid', () {
      test('returns true for alwaysValidPolicy', () {
        expect(alwaysValidPolicy.isValid('value'), isTrue);
      });
      test('returns false for alwaysInvalidPolicy', () {
        expect(alwaysInvalidPolicy.isValid('value'), isFalse);
      });
    });

    group('apply', () {
      test('calls onValid for alwaysValidPolicy', () {
        final result = alwaysValidPolicy.apply(
          value: 'any',
          onValid: () => 'valid',
          onInvalid: (reason) => 'invalid',
        );
        expect(result, equals('valid'));
      });
      test('calls onInvalid for alwaysInvalidPolicy', () {
        final result = alwaysInvalidPolicy.apply(
          value: 'any',
          onValid: () => {},
          onInvalid: (reason) => reason,
        );
        expect(result, isA<DummyIsAlwaysInvalid>());
      });
    });

    group('enforce', () {
      test('returns normally for alwaysValidPolicy', () {
        expect(() => alwaysValidPolicy.enforce('any', onValid: () {}), returnsNormally);
      });
      test('throws for alwaysInvalidPolicy', () {
        expect(() => alwaysInvalidPolicy.enforce('any', onValid: () {}), throwsA(isA<PolicyViolationException>()));
      });
    });
  });
}
