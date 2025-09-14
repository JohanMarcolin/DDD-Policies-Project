import 'package:test/test.dart';
import '../../../../domain/policies/validation_policies/validation_policy.dart';
import '../../../../domain/policies/validation_policies/validation_policy_result.dart';
import '../../../../domain/policies/policy_exception.dart';

class AlwaysValidPolicy extends ValidationPolicy<String> {
  const AlwaysValidPolicy();
  @override
  ValidationPolicyResult evaluateValidity(String value) => Valid();
}

class AlwaysInvalidPolicy extends ValidationPolicy<String> {
  const AlwaysInvalidPolicy();
  @override
  ValidationPolicyResult evaluateValidity(String value) =>
      Invalid(reason: 'fail');
}

void main() {
  group('ValidationPolicy', () {
    test('isValid returns true for valid', () {
      final policy = AlwaysValidPolicy();
      expect(policy.isValid('anything'), isTrue);
    });
    test('isValid returns false for invalid', () {
      final policy = AlwaysInvalidPolicy();
      expect(policy.isValid('anything'), isFalse);
    });
    test('enforce does nothing for valid', () {
      final policy = AlwaysValidPolicy();
      expect(() => policy.enforce('anything'), returnsNormally);
    });
    test('enforce throws for invalid', () {
      final policy = AlwaysInvalidPolicy();
      expect(() => policy.enforce('anything'),
          throwsA(isA<ValidationPolicyException>()));
    });
  });
}
