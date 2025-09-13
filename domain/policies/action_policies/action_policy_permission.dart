sealed class ActionPolicyPermission {}

class Granted extends ActionPolicyPermission {}

class Denied<TReason> extends ActionPolicyPermission {
  Denied({required this.reason});

  final TReason reason;

  @override
  String toString() => 'Policy Permission Denied: ${reason.toString()}';
}
