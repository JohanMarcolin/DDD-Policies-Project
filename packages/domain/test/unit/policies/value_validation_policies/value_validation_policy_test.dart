import 'package:domain/policies/policy_violation_exception.dart';
import 'package:test/test.dart';
import '../../utils/policies/value_validation_policies/dummy_value_validation_policy.dart';

void main() {
  group('ValueValidationPolicy', () {
    final alwaysValidPolicy = DummyAlwaysValidValidationPolicy();
    final alwaysInvalidPolicy = DummyAlwaysInvalidValidationPolicy();

    group('isValid', () {
      test('returns true for alwaysValidPolicy', () {
        expect(alwaysValidPolicy.isValid('value'), isTrue,
            reason: 'Should be valid for DummyAlwaysValidValidationPolicy');
      });
      test('returns false for alwaysInvalidPolicy', () {
        expect(alwaysInvalidPolicy.isValid('value'), isFalse,
            reason: 'Should not be valid for DummyAlwaysInvalidValidationPolicy');
      });
    });

    group('apply', () {
      test('calls onValid for alwaysValidPolicy', () {
        final result = alwaysValidPolicy.apply(
          value: 'any',
          onValid: () => 'valid',
          onInvalid: (reason) => 'invalid',
        );
        expect(result, equals('valid'), reason: 'Should call onValid for DummyAlwaysValidValidationPolicy');
      });
      test('calls onInvalid for alwaysInvalidPolicy', () {
        final result = alwaysInvalidPolicy.apply(
          value: 'any',
          onValid: () => {},
          onInvalid: (reason) => reason,
        );
        expect(result, isA<DummyIsAlwaysInvalid>(), reason: 'Should call onInvalid and return DummyIsAlwaysInvalid');
      });
    });

    group('enforce', () {
      test('returns normally for alwaysValidPolicy', () {
        expect(() => alwaysValidPolicy.enforce('any', onValid: () {}), returnsNormally,
            reason: 'Should not throw for DummyAlwaysValidValidationPolicy');
      });
      test('throws for alwaysInvalidPolicy', () {
        expect(() => alwaysInvalidPolicy.enforce('any', onValid: () {}), throwsA(isA<PolicyViolationException>()),
            reason: 'Should throw PolicyViolationException for DummyAlwaysInvalidValidationPolicy');
      });
    });
  });
}
