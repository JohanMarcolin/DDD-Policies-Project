import 'package:domain/policies/validation_policies/validation_policy.dart';

final class DummyAlwaysValidValidationPolicy extends ValidationPolicy<String> {
  DummyAlwaysValidValidationPolicy() : super(validate: (value) => Valid());
}

final class DummyAlwaysInvalidValidationPolicy extends ValidationPolicy<String> {
  DummyAlwaysInvalidValidationPolicy()
      : super(validate: (value) {
          return Invalid(reason: DummyIsAlwaysInvalid());
        });
}

sealed class DummyInvalidReason {}

class DummyIsAlwaysInvalid implements DummyInvalidReason {}
