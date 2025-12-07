import 'package:domain/policies/policy_violation_exception.dart';
import 'package:equatable/equatable.dart';

/// Function signature for performing an authorization check.
typedef Authorize<TActor, TResource, TReason extends ActionUnauthorizedReason> = ActionAuthorizationResult<TReason>
    Function(TActor actor, TResource resource);

/// Callback invoked when authorization succeeds.
typedef OnAuthorized<TReturn> = TReturn Function();

/// Callback invoked when authorization fails, with an unauthorized reason.
typedef OnUnauthorized<TReturn, TReason extends ActionUnauthorizedReason> = TReturn Function(TReason reason);

/// Abstract base for action authorization policies.
///
/// Provides functionality for checking if an [actor] is authorized to perform an action on a [resource], as determined by the policy.
/// [TActor] is the type of the actor (e.g., [Admin]).
/// [TResource] is the type of the resource being acted upon (e.g., [User]).
/// [TReason] describes why the action is unauthorized based on the policy.
/// [TReturn] can be any type, including a [Future], enabling both sync and async callbacks.
///
/// ### Example:
/// ```dart
/// // Define a concrete policy, e.g., a policy for updating user settings.
/// class UpdateUserSettingsPolicy extends ActionAuthorizationPolicy<User, User, UpdateUserSettingsUnauthorizedReason> {
///   UpdateUserSettingsPolicy()
///     : super(authorize: (User actor, User resource) {
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
/// print(result); // 'allowed'
///
/// /// final result2 = policy.apply(
///   actor: user1,
///   resource: user2,
///   onAuthorized: () => 'allowed',
///   onUnauthorized: (reason) => 'unauthorized: ${reason.toString()}',
/// );
///
/// print(result); // 'unauthorized: CanOnlyUpdateOwnSettings'
/// ```
abstract base class ActionAuthorizationPolicy<TActor, TResource, TReason extends ActionUnauthorizedReason> {
  const ActionAuthorizationPolicy({
    required Authorize<TActor, TResource, TReason> authorize,
  }) : _authorize = authorize;

  final Authorize<TActor, TResource, TReason> _authorize;

  /// Returns `true` if the [actor] is authorized to perform an action on the [resource], otherwise `false`.
  bool isAuthorized(TActor actor, TResource resource) => _authorize(actor, resource) is Authorized;

  /// Applies the policy to the context of the given [actor] and [resource].
  ///
  /// If [Authorized], calls [onAuthorized].
  /// If [Unauthorized], calls [onUnauthorized] and provides a [TReason].
  /// Returns [TReturn] from the invoked callback, which can be synchronous or asynchronous.
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

  /// Enforces the policy on the context of the given [actor] and [resource].
  ///
  /// If [Authorized], calls [onAuthorized].
  /// If [Unauthorized], throws [ActionAuthorizationPolicyViolationException] and provides a [TReason].
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

/// Base class for the result of an action authorization check.
sealed class ActionAuthorizationResult<TReason> extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Indicates the action is authorized.
class Authorized extends ActionAuthorizationResult<Never> {}

/// Indicates the action is unauthorized and provides the reason.
class Unauthorized<TReason> extends ActionAuthorizationResult<TReason> {
  Unauthorized({required this.reason});

  final TReason reason;
}

/// Base class for unauthorized reasons in action authorization policies.
base class ActionUnauthorizedReason extends Equatable {
  @override
  List<Object?> get props => [];
}
