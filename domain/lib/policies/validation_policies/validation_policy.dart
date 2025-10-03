import 'dart:math';

import '../../../value_objects/email.dart';
import '../../../value_objects/password.dart';
import '../policy_violation_exception.dart';
part 'credentials/email_validation_policy.dart';
part 'credentials/password_validation_policy.dart';

abstract base class ValidationPolicy<TValue, TResult> {
  const ValidationPolicy();

  bool isValid(TValue value);

  TResult validate(TValue value);

  void enforce(TValue value);
}
