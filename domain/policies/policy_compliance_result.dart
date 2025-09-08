part of 'policy.dart';

sealed class PolicyComplianceResult {
  const PolicyComplianceResult();
}

class Compliant extends PolicyComplianceResult {}

class Violation extends PolicyComplianceResult {
  Violation({required this.reason});

  final PolicyViolationReason reason;
}
