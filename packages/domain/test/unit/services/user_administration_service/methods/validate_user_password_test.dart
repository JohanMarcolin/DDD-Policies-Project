import 'package:domain/policies/value_validation_policies/user_credentials/user_credential_policy.dart';
import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:test/test.dart';
import 'package:test_utils/mocks/mock_user_credentials.dart';
import '../../../utils/services/user_administration_service.dart';

void main() {
  late UserAdministrationService userAdministrationService;

  setUp(() {
    userAdministrationService = createTestUserAdministrationService();
  });

  group('UserAdministrationService', () {
    group('validateUserPassword', () {
      test('valid password', () {
        final password = mockValidPassword;
        final result = userAdministrationService.validateUserPassword(
          password,
          onValid: () => true,
          onInvalid: (_) => false,
        );
        expect(result, isTrue);
      });
      test('too short', () {
        final password = mockTooShortPassword;
        userAdministrationService.validateUserPassword(
          password,
          onValid: () => fail('Expected password length ${password.value.length} to be too short.'),
          onInvalid: (reason) => expect(reason, isA<PasswordTooShort>()),
        );
      });
      test('too long', () {
        final password = mockTooLongPassword;
        userAdministrationService.validateUserPassword(
          password,
          onValid: () => fail('Expected password length ${password.value.length} to be too long.'),
          onInvalid: (reason) => expect(reason, isA<PasswordTooLong>()),
        );
      });
      test('missing uppercase', () {
        final password = mockMissingUppercasePassword;
        userAdministrationService.validateUserPassword(
          password,
          onValid: () => fail('Expected password "$password" to be missing uppercase.'),
          onInvalid: (reason) => expect(reason, isA<PasswordMissingUppercase>()),
        );
      });
      test('missing lowercase', () {
        final password = mockMissingLowercasePassword;
        userAdministrationService.validateUserPassword(
          password,
          onValid: () => fail('Expected password "$password" to be missing lowercase.'),
          onInvalid: (reason) => expect(reason, isA<PasswordMissingLowercase>()),
        );
      });
      test('missing number', () {
        final password = mockMissingNumberPassword;
        userAdministrationService.validateUserPassword(
          password,
          onValid: () => fail('Expected password "$password" to be missing number.'),
          onInvalid: (reason) => expect(reason, isA<PasswordMissingNumber>()),
        );
      });
      test('missing special character', () {
        final password = mockMissingSpecialCharPassword;
        userAdministrationService.validateUserPassword(
          password,
          onValid: () => fail('Expected password "$password" to be missing special character.'),
          onInvalid: (reason) => expect(reason, isA<PasswordMissingSpecialCharacter>()),
        );
      });
    });
  });
}
