sealed class ValidationPolicyResult {}

class Valid extends ValidationPolicyResult {}

class Invalid<TReason> extends ValidationPolicyResult {
  Invalid({required this.reason});

  final TReason reason;

  @override
  String toString() => 'Policy Permission Invalid: ${reason.toString()}';
}
