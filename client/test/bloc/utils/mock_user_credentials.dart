import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/password.dart';

Email mockValidEmail = Email('new_email@example.com');

Email mockInvalidEmail = Email('invalid_email');
Email mockMissingAtEmail = Email('invalidemail.com');
Email mockMissingDomainEmail = Email('invalid@');
Email mockMissingUsernameEmail = Email('@domain.com');
Email mockDoubleAtEmail = Email('invalid@@domain.com');
Email mockSpaceInEmail = Email('invalid email@domain.com');
Email mockSpecialCharEmail = Email('invalid!email@domain.com');

List<Email> mockInvalidEmails = [
  mockInvalidEmail,
  mockMissingAtEmail,
  mockMissingDomainEmail,
  mockMissingUsernameEmail,
  mockDoubleAtEmail,
  mockSpaceInEmail,
  mockSpecialCharEmail,
];

Password mockValidPassword = PasswordValidationPolicy.generatePassword();

Password mockTooShortPassword = Password(
  'p' * (PasswordValidationPolicy.minLength - 1),
);
Password mockTooLongPassword = Password(
  'p' * (PasswordValidationPolicy.maxLength + 1),
);
Password mockMissingUppercasePassword = Password('password1!');
Password mockMissingLowercasePassword = Password('PASSWORD1!');
Password mockMissingNumberPassword = Password('Password!');
Password mockMissingSpecialCharPassword = Password('Password1');

List<Password> mockInvalidPasswords = [
  mockTooShortPassword,
  mockTooLongPassword,
  mockMissingUppercasePassword,
  mockMissingLowercasePassword,
  mockMissingNumberPassword,
  mockMissingSpecialCharPassword,
];
