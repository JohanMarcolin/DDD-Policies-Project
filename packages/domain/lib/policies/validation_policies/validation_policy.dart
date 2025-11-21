import 'dart:math';

import 'package:equatable/equatable.dart';

import '../../../value_objects/email.dart';
import '../../../value_objects/password.dart';
import '../policy_violation_exception.dart';
part 'credentials/email_validation_policy.dart';
part 'credentials/password_validation_policy.dart';

abstract base class ValidationPolicy<TValue> {
  const ValidationPolicy({required this.validate});

  final ValidationPolicyResult Function(TValue) validate;

  bool isValid(TValue value) => validate(value) is Valid;

  void enforce(TValue value) {
    final result = validate(value);
    if (result is Valid) {
      return;
    } else {
      throw ValidationPolicyViolationException((result as Invalid).reason);
    }
  }
}

sealed class ValidationPolicyResult extends Equatable {
  @override
  List<Object?> get props => [];
}

class Valid extends ValidationPolicyResult {}

class Invalid<TReason> extends ValidationPolicyResult {
  Invalid({required this.reason});

  final TReason reason;
}
