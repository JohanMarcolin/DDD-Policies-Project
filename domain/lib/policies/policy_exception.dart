sealed class PolicyViolationException<TReason> implements Exception {
  PolicyViolationException(this.reason);

  final TReason reason;
  @override
  String toString() => 'PolicyViolationException: ${reason.toString()}';
}

class ActionPolicyViolationException extends PolicyViolationException {
  ActionPolicyViolationException(super.reason);
}

class ValidationPolicyViolationException extends PolicyViolationException {
  ValidationPolicyViolationException(super.reason);
}
