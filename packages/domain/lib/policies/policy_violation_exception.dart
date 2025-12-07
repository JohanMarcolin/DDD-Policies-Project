base class PolicyViolationException<TPolicyViolationReason> implements Exception {
  PolicyViolationException(this.reason);

  final TPolicyViolationReason reason;

  @override
  String toString() => '${runtimeType.toString()}: reason:${reason.runtimeType.toString()}';
}

final class ValidationPolicyViolationException extends PolicyViolationException {
  ValidationPolicyViolationException(super.reason);
}
