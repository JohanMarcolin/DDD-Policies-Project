import 'package:domain/policies/policy_violation_exception.dart';
import 'package:equatable/equatable.dart';

/// Defines a function that checks if an [actor] is authorized to perform an action on a [resource].
/// Returns [Authorized] if permitted, or [Unauthorized] with a reason.
typedef Authorize<TActor, TResource, TReason extends ActionUnauthorizedReason> = ActionAuthorizationResult<TReason>
    Function(TActor actor, TResource resource);

/// Callback invoked when authorization succeeds.
/// [TReturn] is the callback's return type, supports sync and async.
typedef OnAuthorized<TReturn> = TReturn Function();

/// Callback invoked when authorization fails, providing the reason.
/// [TReturn] is the callback's return type, supports sync and async.
typedef OnUnauthorized<TReturn, TReason extends ActionUnauthorizedReason> = TReturn Function(TReason reason);

/// Base class for policies that determine if an [actor] is authorized to perform an action on a [resource] based on the implementing policy.
/// Provides methods to apply or enforce authorization logic, invoking the appropriate callbacks.
///
/// [TActor]: actor type (e.g., User, Admin)
/// [TResource]: resource type (e.g., Document, Account)
/// [TReason]: reason type for unauthorized actions (extends [ActionUnauthorizedReason])
/// [TReturn]: callback return type, supports sync/async
///
/// Use for defining authorization rules for actions in the domain.
///
/// Example:
/// ```dart
/// // Define a policy involving an action that should be authorized, e.g., a policy for updating user settings.
/// class UpdateUserSettingsPolicy extends ActionAuthorizationPolicy<User, User, UpdateUserSettingsUnauthorizedReason> {
///   UpdateUserSettingsPolicy()
///     : super(authorize: (actor, resource) {
///         if (actor.id == resource.id) {
///           return Authorized();
///         } else {
///           return Unauthorized(reason: CanOnlyUpdateOwnSettings());
///         }
///       });
/// }
///
/// // Define reasons why an action might be unauthorized.
/// sealed class UpdateUserSettingsUnauthorizedReason extends ActionUnauthorizedReason {}
///
/// final class CanOnlyUpdateOwnSettings extends UpdateUserSettingsUnauthorizedReason {}
///
/// // Using the policy:
/// final policy = UpdateUserSettingsPolicy();
/// final user1 = User(id: '1');
/// final user2 = User(id: '2');
///
/// final result1 = policy.apply(
///   actor: user1,
///   resource: user1,
///   onAuthorized: () => 'allowed',
///   onUnauthorized: (reason) => 'unauthorized: ${reason.toString()}',
/// );
///
/// // result1 == 'allowed'
///
/// /// final result2 = policy.apply(
///   actor: user1,
///   resource: user2,
///   onAuthorized: () => 'allowed',
///   onUnauthorized: (reason) => 'unauthorized: ${reason.toString()}',
/// );
/// // result2 == 'unauthorized: CanOnlyUpdateOwnSettings'
/// ```
abstract base class ActionAuthorizationPolicy<TActor, TResource, TReason extends ActionUnauthorizedReason> {
  const ActionAuthorizationPolicy({
    required Authorize<TActor, TResource, TReason> authorize,
  }) : _authorize = authorize;

  final Authorize<TActor, TResource, TReason> _authorize;

  /// Returns `true` if the [actor] is authorized to perform an action on the [resource], otherwise `false`.
  bool isAuthorized(TActor actor, TResource resource) => _authorize(actor, resource) is Authorized;

  /// Applies the policy to the given [actor] and [resource].
  ///
  /// If the action is authorized, calls [onAuthorized].
  /// If unauthorized, calls [onUnauthorized] with the [TReason].
  /// Returns [TReturn] from the invoked callback.
  TReturn apply<TReturn>({
    required TActor actor,
    required TResource resource,
    required OnAuthorized<TReturn> onAuthorized,
    required OnUnauthorized<TReturn, TReason> onUnauthorized,
  }) {
    return switch (_authorize(actor, resource)) {
      Authorized() => onAuthorized(),
      Unauthorized(:final reason) => onUnauthorized(reason),
    };
  }

  /// Enforces the policy for the given [actor] and [resource].
  ///
  /// If authorized, calls [onAuthorized].
  /// If unauthorized, throws [PolicyViolationException] with the [TReason].
  TReturn enforce<TReturn>(
    TActor actor,
    TResource resource, {
    required OnAuthorized<TReturn> onAuthorized,
  }) {
    return apply<TReturn>(
      actor: actor,
      resource: resource,
      onAuthorized: onAuthorized,
      onUnauthorized: (reason) => throw PolicyViolationException<TReason>(reason),
    );
  }
}

/// Represents the result of an action authorization check.
sealed class ActionAuthorizationResult<TReason> extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Indicates that the action is authorized.
class Authorized extends ActionAuthorizationResult<Never> {}

/// Indicates that the action is unauthorized and provides the reason.
class Unauthorized<TReason> extends ActionAuthorizationResult<TReason> {
  Unauthorized({required this.reason});

  final TReason reason;
}

/// Base class for reasons why an action was unauthorized.
///
/// Extend this class to define specific reasons for unauthorized actions in your policies.
base class ActionUnauthorizedReason extends Equatable {
  @override
  List<Object?> get props => [];
}
