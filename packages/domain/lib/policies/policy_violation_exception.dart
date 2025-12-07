sealed class PolicyViolationException<TPolicyViolationReason> implements Exception {
  PolicyViolationException(this.reason);

  final TPolicyViolationReason reason;
  @override
  String toString() => 'PolicyViolationException: reason:${reason.runtimeType.toString()}';
}

class ActionAuthorizationPolicyViolationException<TUnauthorizedReason>
    extends PolicyViolationException<TUnauthorizedReason> {
  ActionAuthorizationPolicyViolationException(super.reason);
}

class ValidationPolicyViolationException extends PolicyViolationException {
  ValidationPolicyViolationException(super.reason);
}
