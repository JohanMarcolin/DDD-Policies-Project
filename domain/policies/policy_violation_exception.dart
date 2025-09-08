import 'policy.dart';

class PolicyViolationException implements Exception {
  PolicyViolationException(this.reason);

  final PolicyViolationReason reason;
  @override
  String toString() => 'PolicyViolationException: $reason';
}
