import 'package:domain/policies/policy_violation_exception.dart';
import 'package:equatable/equatable.dart';

/// Defines a function that checks if a [value] is valid according to the policy.
/// Returns [Valid] if permitted, or [Invalid] with a reason.
typedef Validate<TValue, TReason extends ValueInvalidReason> = ValidationResult<TReason> Function(TValue value);

/// Callback invoked when validation succeeds.
/// [TReturn] is the callback's return type, support sync and async.
typedef OnValid<TReturn> = TReturn Function();

/// Callback invoked when validation fails, providing the reason.
/// [TReturn] is the callback's return type, support sync and async.
typedef OnInvalid<TReturn, TReason extends ValueInvalidReason> = TReturn Function(TReason reason);

/// Base class for policies that determine if a [value] is valid according to the implementing policy.
/// Provides methods to apply or enforce validation logic, invoking the appropriate callbacks.
///
/// [TValue]: type being validated (e.g., String, Email)
/// [TReason]: reason type for invalid values (extends [ValueInvalidReason])
/// [TReturn]: callback return type, supports both sync and async
/// 
/// Use for defining validation rules for value objects in the domain.
/// 
/// Example:
/// ```dart
/// // Define a policy for a value that needs validation, e.g., a validation policy for emails:
/// final class EmailValidationPolicy extends ValueValidationPolicy<String, EmailInvalidReason> {
///   EmailValidationPolicy() : super(validate: _validateEmail);
///
///   static ValidationResult<EmailInvalidReason> _validateEmail(String email) {
///     if (email.contains('@')) {
///       return Valid();
///     }
///     return Invalid(reason: EmailMissingAtSign());
///   }
/// }
///
/// // Define reasons why an email might be invalid.
/// sealed class EmailInvalidReason extends ValueInvalidReason {}
///
/// final class EmailMissingAtSign extends EmailInvalidReason {}
///
/// // Usage:
/// final policy = EmailValidationPolicy();
/// final result1 = policy.apply(
///   value: 'valid@example.com',
///   onValid: () => 'valid',
///   onInvalid: (reason) => 'invalid',
/// );
/// // result1 == 'valid'
///
/// final result2 = policy.apply(
///   value: 'invalid-example',
///   onValid: () => 'valid',
///   onInvalid: (reason) => 'invalid: $reason.toString()',
/// );
/// // result2 == 'invalid: EmailMissingAtSign'
/// ```
abstract base class ValueValidationPolicy<TValue, TReason extends ValueInvalidReason> {
  ValueValidationPolicy({
    required Validate<TValue, TReason> validate,
  }) : _validate = validate;

  final Validate<TValue, TReason> _validate;

  /// Returns `true` if the [value] is valid according to the policy, otherwise `false`.
  bool isValid(TValue value) => _validate(value) is Valid;

  /// Applies the policy to the given [value].
  ///
  /// If valid, calls [onValid].
  /// If invalid, calls [onInvalid] with the reason ([TReason]).
  /// Returns [TReturn] from the invoked callback.
  TReturn apply<TReturn>({
    required TValue value,
    required OnValid<TReturn> onValid,
    required OnInvalid<TReturn, TReason> onInvalid,
  }) {
    return switch (_validate(value)) {
      Valid() => onValid(),
      Invalid(:final reason) => onInvalid(reason),
    };
  }

  /// Enforces the policy for the given [value].
  ///
  /// If valid, calls [onValid].
  /// If invalid, throws [PolicyViolationException] with the reason ([TReason]).
  TReturn enforce<TReturn>(
    TValue value, {
    required OnValid<TReturn> onValid,
  }) {
    return apply<TReturn>(
      value: value,
      onValid: onValid,
      onInvalid: (reason) => throw PolicyViolationException<TReason>(reason),
    );
  }
}

/// Represents the result of a validation check.
sealed class ValidationResult<TReason> extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Indicates the value is valid.
class Valid extends ValidationResult<Never> {}

/// Indicates the value is invalid and provides the reason.
class Invalid<TReason> extends ValidationResult<TReason> {
  /// The domain-specific failure reason for the invalid value.
  Invalid({required this.reason});
  final TReason reason;
}

/// Base class for reasons why a value was invalid in validation policies.
///
/// Extend this class to define domain-specific reason types, e.g. `EmailValidationFailure`.
base class ValueInvalidReason extends Equatable {
  @override
  List<Object?> get props => [];
}
