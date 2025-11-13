import 'package:domain/policies/action_policies/action_policy.dart';

final class DummyAlwaysAuthorizedActionPolicy extends ActionPolicy<String, String> {
  DummyAlwaysAuthorizedActionPolicy() : super(authorize: (String initiator, String target) => Authorized());
}

final class DummyAlwaysUnauthorizedActionPolicy extends ActionPolicy<String, String> {
  DummyAlwaysUnauthorizedActionPolicy()
      : super(authorize: (String initiator, String target) => Unauthorized(reason: DummyIsAlwaysUnauthorized()));
}

class DummyIsAlwaysUnauthorized {}
