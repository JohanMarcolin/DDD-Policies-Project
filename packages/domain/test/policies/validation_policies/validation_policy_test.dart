import 'package:domain/policies/policy_violation_exception.dart';
import 'package:test/test.dart';
import '../../utils/policies/validation_policies/dummy_validation_policy.dart';

void main() {
  group('ValidationPolicy', () {
    test('isValid returns true for valid', () {
      final policy = DummyAlwaysValidValidationPolicy();
      expect(policy.isValid('anything'), isTrue);
    });
    test('isValid returns false for invalid', () {
      final policy = DummyAlwaysInvalidValidationPolicy();
      expect(policy.isValid('anything'), isFalse);
    });
    test('enforce does nothing for valid', () {
      final policy = DummyAlwaysValidValidationPolicy();
      expect(() => policy.enforce('anything'), returnsNormally);
    });
    test('enforce throws for invalid', () {
      final policy = DummyAlwaysInvalidValidationPolicy();
      expect(() => policy.enforce('anything'), throwsA(isA<ValidationPolicyViolationException>()));
    });
  });
}
