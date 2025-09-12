part of 'policy.dart';

sealed class PolicyPermission {
  const PolicyPermission();
}

class PermissionGranted extends PolicyPermission {}

class PermissionDenied extends PolicyPermission {
  PermissionDenied({required this.reason});

  final PolicyPermissionDeniedReason reason;

  @override
  String toString() =>
      'Policy Permission Denied: ${reason.toString()}';
}
