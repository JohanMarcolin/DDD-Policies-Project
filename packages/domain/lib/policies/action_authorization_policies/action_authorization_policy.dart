import 'package:domain/policies/policy_violation_exception.dart';
import 'package:equatable/equatable.dart';

abstract base class ActionAuthorizationPolicy<TInitiator, TTarget, TUnauthorizedReason> {
  const ActionAuthorizationPolicy(
      {required ActionAuthorizationResult<TUnauthorizedReason> Function(TInitiator, TTarget) authorize})
      : _authorize = authorize;

  final ActionAuthorizationResult<TUnauthorizedReason> Function(TInitiator, TTarget) _authorize;

  bool isAuthorized(TInitiator initiator, TTarget target) => _authorize(initiator, target) is Authorized;

  TReturn apply<TReturn>(
    TInitiator initiator,
    TTarget target, {
    required TReturn Function() onAuthorized,
    required TReturn Function(TUnauthorizedReason reason) onUnauthorized,
  }) {
    return switch (_authorize(initiator, target)) {
      Authorized() => onAuthorized(),
      Unauthorized(:final reason) => onUnauthorized(reason),
    };
  }

  TReturn enforce<TReturn>(
    TInitiator initiator,
    TTarget target, {
    required TReturn Function() onAuthorized,
  }) {
    return apply<TReturn>(
      initiator,
      target,
      onAuthorized: () => onAuthorized(),
      onUnauthorized: (reason) => throw ActionAuthorizationPolicyViolationException<TUnauthorizedReason>(reason),
    );
  }
}

sealed class ActionAuthorizationResult<TUnauthorizedReason> extends Equatable {
  @override
  List<Object?> get props => [];
}

class Authorized extends ActionAuthorizationResult<Never> {}

class Unauthorized<TUnauthorizedReason> extends ActionAuthorizationResult<TUnauthorizedReason> {
  Unauthorized({required this.reason});
  final TUnauthorizedReason reason;
}
