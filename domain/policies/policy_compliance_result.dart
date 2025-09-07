part of 'policy.dart';

sealed class PolicyComplianceResult {
  const PolicyComplianceResult();
}

class Compliant extends PolicyComplianceResult {}

class NonCompliant extends PolicyComplianceResult {
  NonCompliant({required this.reason});

  final PolicyNonCompliantReason reason;
}
