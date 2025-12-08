import 'package:domain/policies/value_validation_policies/user_credentials/user_credential_policy.dart';
import 'package:domain/policies/value_validation_policies/value_validation_policy.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/password.dart';

/// Provides mock [Email] and [Password] values for testing purposes.
///
/// Includes valid, invalid, and edge-case credentials for different test scenarios.

Email mockValidEmail = Email('new_email@example.com');

Email mockAnyEmail = Email('anyEmail');
Email mockEmptyEmail = Email('');
Email mockUnknownEmail = Email('unknownEmail');

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
  
Password mockValidPassword = UserPasswordValidationPolicy().generateRandomPassword();

Password mockAnyPassword = Password('anyPassword');
Password mockEmptyPassword = Password('');

Password mockInvalidPassword = Password('invalidPassword');
Password mockTooShortPassword = Password('p' * (UserPasswordValidationPolicy.minLength - 1));
Password mockTooLongPassword = Password('p' * (UserPasswordValidationPolicy.maxLength + 1));
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
