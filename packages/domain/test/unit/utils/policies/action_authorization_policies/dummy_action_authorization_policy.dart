import 'package:domain/policies/action_authorization_policies/action_authorization_policy.dart';

/// A dummy authorization policy that always returns authorized.
///
/// Use to simulate successful authorization in unit tests.
final class DummyAlwaysAuthorizedActionAuthorizationPolicy
    extends ActionAuthorizationPolicy<String, String, DummyUnauthorizedReason> {
  DummyAlwaysAuthorizedActionAuthorizationPolicy()
      : super(authorize: (String initiator, String target) => Authorized());
}

/// A dummy authorization policy that always returns unauthorized.
///
/// Use to simulate failed authorization in unit tests.
final class DummyAlwaysUnauthorizedActionAuthorizationPolicy
    extends ActionAuthorizationPolicy<String, String, DummyUnauthorizedReason> {
  DummyAlwaysUnauthorizedActionAuthorizationPolicy()
      : super(authorize: (String initiator, String target) => Unauthorized(reason: DummyUnauthorizedReason()));
}

final class DummyUnauthorizedReason extends ActionUnauthorizedReason {}
