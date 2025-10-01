import 'dart:math';

import '../../../value_objects/email.dart';
import '../../../value_objects/password.dart';
import '../policy_exception.dart';
import 'validation_policy_result.dart';

part 'credentials/email_validation_policy.dart';
part 'credentials/password_validation_policy.dart';

abstract class ValidationPolicy<TValue> {
  const ValidationPolicy();

  bool isValid(TValue value) => evaluateValidity(value) is Valid;

  ValidationPolicyResult evaluateValidity(TValue value);

  void enforce(TValue value) {
    final result = evaluateValidity(value);
    switch (result) {
      case Valid():
        return;
      case Invalid(:final reason):
        throw ValidationPolicyViolationException(reason);
    }
  }
}
