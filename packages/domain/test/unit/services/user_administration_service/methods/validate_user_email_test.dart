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
    group('validateUserEmail', () {
      group('valid email', () {
        test('should pass validation for a correctly formatted email', () {
          final email = mockValidEmail;
          final isValid = userAdministrationService.validateUserEmail(
            email,
            onValid: () => true,
            onInvalid: (_) => false,
          );
          expect(isValid, isTrue, reason: 'Expected email to be valid.');
        });
      });
      group('invalid email', () {
        for (final invalidEmail in mockInvalidEmails) {
          test('should fail validation for an improperly formatted email', () {
            final email = invalidEmail;
            userAdministrationService.validateUserEmail(
              email,
              onValid: () => fail('Expected email of value "$email" to be invalid.'),
              onInvalid: (reason) => expect(reason, isA<EmailInvalidFormat>()),
            );
          });
        }
      });
    });
  });
}
