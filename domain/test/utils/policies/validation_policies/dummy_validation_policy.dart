import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:domain/policies/validation_policies/validation_policy_result.dart';

class DummyAlwaysValidValidationPolicy<T> extends ValidationPolicy<T> {
  @override
  ValidationPolicyResult evaluateValidity(T value) => Valid();
}

class DummyAlwaysInvalidValidationPolicy<T> extends ValidationPolicy<T> {
  @override
  ValidationPolicyResult evaluateValidity(T value) => Invalid(reason: 'invalid');
}
