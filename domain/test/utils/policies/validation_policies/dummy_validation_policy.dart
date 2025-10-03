import 'package:domain/policies/policy_violation_exception.dart';
import 'package:domain/policies/validation_policies/validation_policy.dart';

final class DummyAlwaysValidValidationPolicy
    extends ValidationPolicy<String, DummyValidationPolicyResult> {
  const DummyAlwaysValidValidationPolicy();

  @override
  bool isValid(String value) => true;

  @override
  void enforce(String value) => {};

  @override
  DummyValidationPolicyResult validate(String value) => DummyValid();
}

final class DummyAlwaysInvalidValidationPolicy
    extends ValidationPolicy<String, DummyValidationPolicyResult> {
  const DummyAlwaysInvalidValidationPolicy();

  @override
  bool isValid(String value) => false;

  @override
  DummyValidationPolicyResult validate(String value) {
    return DummyInvalid(reason: DummyIsAlwaysInvalid());
  }

  @override
  void enforce(String value) {
    throw ValidationPolicyViolationException(DummyIsAlwaysInvalid());
  }
}

sealed class DummyValidationPolicyResult {}

class DummyValid extends DummyValidationPolicyResult {}

class DummyInvalid extends DummyValidationPolicyResult {
  DummyInvalid({required this.reason});

  final DummyInvalidReason reason;
}

sealed class DummyInvalidReason {}

class DummyIsAlwaysInvalid implements DummyInvalidReason {}
