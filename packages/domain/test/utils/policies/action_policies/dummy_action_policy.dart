import 'package:domain/policies/action_authorization_policies/action_authorization_policy.dart';

final class DummyAlwaysAuthorizedActionAuthorizationPolicy
    extends ActionAuthorizationPolicy<String, String, DummyUnauthorizedReason> {
  DummyAlwaysAuthorizedActionAuthorizationPolicy()
      : super(authorize: (String initiator, String target) => Authorized());
}

final class DummyAlwaysUnauthorizedActionAuthorizationPolicy
    extends ActionAuthorizationPolicy<String, String, DummyUnauthorizedReason> {
  DummyAlwaysUnauthorizedActionAuthorizationPolicy()
      : super(authorize: (String initiator, String target) => Unauthorized(reason: DummyUnauthorizedReason()));
}

final class DummyUnauthorizedReason extends ActionUnauthorizedReason {}
