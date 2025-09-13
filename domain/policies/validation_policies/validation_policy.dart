import 'dart:math';

import '../../value_objects/email.dart';
import '../../value_objects/password.dart';
import '../../value_objects/validation_result.dart';
import '../policy_exception.dart';
import 'validation_policy_result.dart';

part 'user_credentials/email_validation_policy.dart';
part 'user_credentials/password_validation_policy.dart';

abstract class ValidationPolicy<TValue> {
  const ValidationPolicy();

  bool isValid(TValue value) => evaluateValidity(value) is Valid;

  ValidationPolicyResult evaluateValidity(TValue value);
}

extension ValidationPolicyEnforcement<TValue> on ValidationPolicy<TValue> {
  void enforce(TValue value) {
    final result = evaluateValidity(value);
    switch (result) {
      case Valid():
        return;
      case Invalid(:final reason):
        throw ValidationPolicyException(reason);
    }
  }
}
