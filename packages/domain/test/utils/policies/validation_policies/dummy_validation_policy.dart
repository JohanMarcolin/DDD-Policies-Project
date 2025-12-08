import 'package:domain/policies/value_validation_policies/value_validation_policy.dart';

final class DummyAlwaysValidValidationPolicy extends ValueValidationPolicy<String, Never> {
  DummyAlwaysValidValidationPolicy() : super(validate: (value) => Valid());
}

final class DummyAlwaysInvalidValidationPolicy extends ValueValidationPolicy<String, DummyInvalidReason> {
  DummyAlwaysInvalidValidationPolicy()
      : super(validate: (value) {
          return Invalid(reason: DummyIsAlwaysInvalid());
        });
}

sealed class DummyInvalidReason extends ValueInvalidReason {}

final class DummyIsAlwaysInvalid extends DummyInvalidReason {}
