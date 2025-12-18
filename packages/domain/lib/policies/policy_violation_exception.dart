/// Exception thrown when a policy (authorization or validation) is violated.
///
/// Used to signal that an attempted action or value failed to meet the requirements of a policy.
/// The generic [TReason] allows this exception to be used for both authorization failures
/// (e.g., `ActionUnauthorizedReason`) and validation failures (e.g., `ValueInvalidReason`).
base class PolicyViolationException<TReason> implements Exception {
  PolicyViolationException(this.reason);

  final TReason reason;

  @override
  String toString() => '${runtimeType.toString()}: reason: ${reason.runtimeType.toString()}';
}
