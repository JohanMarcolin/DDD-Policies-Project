part of 'policy.dart';

/// Exception thrown when a policy denies permission.
///
/// Contains the [reason] for denial.
///
/// Example:
/// ```dart
/// try {
///   policy.enforce(user, target, onPermissionGranted: () => ...);
/// } on PolicyPermissionDeniedException catch (e) {
///   print(e.reason);
/// }
/// ```
class PolicyPermissionDeniedException implements Exception {
  PolicyPermissionDeniedException(this.reason);

  final PolicyPermissionDeniedReason reason;
  @override
  String toString() => 'PolicyPermissionDeniedException: $reason';
}
