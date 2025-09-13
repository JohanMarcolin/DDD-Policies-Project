sealed class PolicyException<TReason> implements Exception {
  PolicyException(this.reason);

  final TReason reason;
  @override
  String toString() => 'PolicyException: ${reason.toString()}';
}

class ActionPolicyException extends PolicyException {
  ActionPolicyException(super.reason);
}

class ValidationPolicyException extends PolicyException {
  ValidationPolicyException(super.reason);
}
