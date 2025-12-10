import 'package:domain/policies/value_validation_policies/value_validation_policy.dart';

/// A dummy validation policy that always returns valid.
///
/// Use to simulate successful validation in unit tests.
final class DummyAlwaysValidValidationPolicy extends ValueValidationPolicy<String, Never> {
  DummyAlwaysValidValidationPolicy() : super(validate: (value) => Valid());
}

/// A dummy validation policy that always returns invalid.
///
/// Use to simulate failed validation in unit tests.
final class DummyAlwaysInvalidValidationPolicy extends ValueValidationPolicy<String, DummyInvalidReason> {
  DummyAlwaysInvalidValidationPolicy()
      : super(validate: (value) {
          return Invalid(reason: DummyIsAlwaysInvalid());
        });
}

sealed class DummyInvalidReason extends ValueInvalidReason {}

final class DummyIsAlwaysInvalid extends DummyInvalidReason {}
