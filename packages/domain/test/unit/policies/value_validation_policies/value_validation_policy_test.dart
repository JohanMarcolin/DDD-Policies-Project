import 'package:domain/policies/policy_violation_exception.dart';
import 'package:domain/policies/value_validation_policies/value_validation_policy.dart';
import 'package:test/test.dart';

void main() {
  final alwaysValidPolicy = _DummyAlwaysValidValidationPolicy();
  final alwaysInvalidPolicy = _DummyAlwaysInvalidValidationPolicy();

  group('ValueValidationPolicy', () {
    test('isValid returns true for alwaysValidPolicy', () {
      expect(alwaysValidPolicy.isValid('value'), isTrue, reason: 'Should be valid');
    });
    test('isValid returns false for alwaysInvalidPolicy', () {
      expect(alwaysInvalidPolicy.isValid('value'), isFalse, reason: 'Should be invalid');
    });

    test('apply calls onValid for alwaysValidPolicy', () {
      final result = alwaysValidPolicy.apply(
        value: 'any',
        onValid: () => 'valid',
        onInvalid: (reason) => 'invalid',
      );
      expect(result, equals('valid'), reason: 'Should call onValid');
    });
    test('apply calls onInvalid for alwaysInvalidPolicy', () {
      final result = alwaysInvalidPolicy.apply(
        value: 'any',
        onValid: () => {},
        onInvalid: (reason) => reason,
      );
      expect(result, isA<_DummyIsAlwaysInvalid>(), reason: 'Should call onInvalid');
    });

    test('enforce returns normally for alwaysValidPolicy', () {
      expect(() => alwaysValidPolicy.enforce('any', onValid: () {}), returnsNormally, reason: 'Should not throw');
    });
    test('enforce throws exception for alwaysInvalidPolicy', () {
      expect(
        () => alwaysInvalidPolicy.enforce('any', onValid: () {}),
        throwsA(predicate((e) => e is PolicyViolationException && e.reason is _DummyIsAlwaysInvalid)),
        reason: 'Should throw exception with reason',
      );
    });
  });
}

/// A dummy validation policy that always returns valid.
final class _DummyAlwaysValidValidationPolicy extends ValueValidationPolicy<String, Never> {
  _DummyAlwaysValidValidationPolicy() : super(validate: (value) => Valid());
}

/// A dummy validation policy that always returns invalid.
final class _DummyAlwaysInvalidValidationPolicy extends ValueValidationPolicy<String, _DummyInvalidReason> {
  _DummyAlwaysInvalidValidationPolicy()
      : super(validate: (value) {
          return Invalid(reason: _DummyIsAlwaysInvalid());
        });
}

sealed class _DummyInvalidReason extends ValueInvalidReason {}

final class _DummyIsAlwaysInvalid extends _DummyInvalidReason {}
