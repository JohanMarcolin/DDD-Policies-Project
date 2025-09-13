class ValidationResult {
  const ValidationResult();
}

class ValidationSuccess extends ValidationResult {
  const ValidationSuccess();
}

class ValidationError extends ValidationResult {
  const ValidationError({required this.reason});

  final ValidationErrorReason reason;
}

class ValidationErrorReason {
  const ValidationErrorReason();
}

class ValidationErrorException implements Exception {
  ValidationErrorException(this.reason);

  final ValidationErrorReason reason;
  @override
  String toString() => 'ValidationErrorException: $reason';
}
