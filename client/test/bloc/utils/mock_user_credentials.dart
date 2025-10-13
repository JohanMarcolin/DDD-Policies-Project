import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/password.dart';

Email mockValidEmail = Email('new_email@example.com');
Email mockInvalidEmail = Email('invalid_email');

Password mockValidPassword = PasswordValidationPolicy.generatePassword();
Password mockInvalidPassword = Password('short');
