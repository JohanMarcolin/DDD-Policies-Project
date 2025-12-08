import 'package:domain/policies/policy_violation_exception.dart';
import 'package:equatable/equatable.dart';

/// Function signature for performing a validation check.
typedef Validate<TValue, TReason extends ValueInvalidReason> = ValidationResult<TReason> Function(TValue value);

/// Callback invoked when validation succeeds.
typedef OnValid<TReturn> = TReturn Function();

/// Callback invoked when validation fails, with a failure reason.
typedef OnInvalid<TReturn, TReason extends ValueInvalidReason> = TReturn Function(TReason reason);

/// Abstract base for validation policies.
///
/// Provides functionality for checking if a [value] is valid according to the policy.
/// [TValue] is the type being validated (e.g., String, Email).
/// [TReason] describes why the value is invalid, must extend [ValueInvalidReason].
/// [TReturn] can be any type, including a [Future], enabling both sync and async callbacks.
///
/// ### Example:
/// ```dart
/// // Define a domain-specific failure reason:
/// class EmailValidationFailure extends ValueInvalidReason {
///   final String message;
///   EmailValidationFailure(this.message);
///   @override
///   List<Object?> get props => [message];
/// }
///
/// // Define a concrete policy:
/// final policy = ValueValidationPolicy<String, EmailValidationFailure>(
///   validate: (email) =>
///     email.contains('@')
///       ? Valid()
///       : Invalid(reason: EmailValidationFailure('Missing @')),
/// );
///
/// final result = policy.apply(
///   value: 'testexample.com',
///   onValid: () => 'valid',
///   onInvalid: (reason) => 'invalid: ${reason.message}',
/// );
/// print(result); // 'invalid: Missing @'
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
  /// If invalid, calls [onInvalid] with the failure reason ([TReason]).
  /// Returns [TReturn] from the invoked callback, which can be synchronous or asynchronous.
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
  /// If invalid, throws [PolicyViolationException] with the failure reason ([TReason]).
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

/// Base class for the result of a validation check.
sealed class ValidationResult<TReason> extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Indicates the value is valid.
class Valid extends ValidationResult<Never> {}

/// Indicates the value is invalid and provides the failure reason.
class Invalid<TReason> extends ValidationResult<TReason> {
  /// The domain-specific failure reason for the invalid value.
  Invalid({required this.reason});
  final TReason reason;
}

/// Base class for failure reasons in validation policies.
///
/// Extend this class to define domain-specific failure reason types, e.g. `EmailValidationFailure`.
/// Use as the generic type for [Invalid] and policy exceptions to provide structured, type-safe reasons.
base class ValueInvalidReason extends Equatable {
  @override
  List<Object?> get props => [];
}
