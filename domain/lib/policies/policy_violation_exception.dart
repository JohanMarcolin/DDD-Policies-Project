sealed class PolicyViolationException<TPolicyViolationReason>
    implements Exception {
  PolicyViolationException(this.reason);

  final TPolicyViolationReason reason;
  @override
  String toString() => 'PolicyViolationException: reason:${reason.toString()}';
}

sealed class PolicyViolationReason {
  @override
  String toString() => runtimeType.toString();
}

class ActionPolicyViolationException extends PolicyViolationException {
  ActionPolicyViolationException(super.reason);
}

class ValidationPolicyViolationException extends PolicyViolationException {
  ValidationPolicyViolationException(super.reason);
}
