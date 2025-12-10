import 'package:domain/policies/value_validation_policies/user_credentials/user_credential_policy.dart';
import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:domain/value_objects/password.dart';
import 'package:test/test.dart';
import '../../../utils/mock/mock_users.dart';
import '../../../utils/services/user_administration_service.dart';

void main() {
  late UserAdministrationService userAdministrationService;

  setUp(() {
    userAdministrationService =
        createTestUserAdministrationService([user, otherUser, admin, otherAdmin, analyst, otherAnalyst]);
  });

  group('UserAdministrationService', () {
    group('validateUserPassword', () {
      test('valid password', () {
        final password = Password('Valid123!');
        final result = userAdministrationService.validateUserPassword(
          password,
          onValid: () => true,
          onInvalid: (_) => false,
        );
        expect(result, isTrue);
      });
      test('too short', () {
        final password = Password('A1!a');
        final result = userAdministrationService.validateUserPassword(
          password,
          onValid: () => false,
          onInvalid: (reason) => reason is PasswordTooShort,
        );
        expect(result, isTrue);
      });
      test('too long', () {
        final password = Password('A' * 65 + '1!a');
        final result = userAdministrationService.validateUserPassword(
          password,
          onValid: () => false,
          onInvalid: (reason) => reason is PasswordTooLong,
        );
        expect(result, isTrue);
      });
      test('missing uppercase', () {
        final password = Password('valid123!');
        final result = userAdministrationService.validateUserPassword(
          password,
          onValid: () => false,
          onInvalid: (reason) => reason is PasswordMissingUppercase,
        );
        expect(result, isTrue);
      });
      test('missing lowercase', () {
        final password = Password('VALID123!');
        final result = userAdministrationService.validateUserPassword(
          password,
          onValid: () => false,
          onInvalid: (reason) => reason is PasswordMissingLowercase,
        );
        expect(result, isTrue);
      });
      test('missing number', () {
        final password = Password('ValidTest!');
        final result = userAdministrationService.validateUserPassword(
          password,
          onValid: () => false,
          onInvalid: (reason) => reason is PasswordMissingNumber,
        );
        expect(result, isTrue);
      });
      test('missing special character', () {
        final password = Password('Valid1234');
        final result = userAdministrationService.validateUserPassword(
          password,
          onValid: () => false,
          onInvalid: (reason) => reason is PasswordMissingSpecialCharacter,
        );
        expect(result, isTrue);
      });
    });
  });
}
