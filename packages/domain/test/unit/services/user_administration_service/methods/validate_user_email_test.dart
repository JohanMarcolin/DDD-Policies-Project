import 'package:domain/policies/value_validation_policies/user_credentials/user_credential_policy.dart';
import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:domain/value_objects/email.dart';
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
    group('validateUserEmail', () {
      group('valid email', () {
        test('should pass validation for a well-formed email', () {
          final email = Email('new.email@example.com');
          userAdministrationService.validateUserEmail(
            email,
            onValid: () {
              // If this callback is called, the email is valid.
            },
            onInvalid: (reason) {
              fail('Expected email to be valid, but got invalid reason: $reason');
            },
          );
        });
      });
      group('invalid email', () {
        test('should fail validation for an improperly formatted email', () {
          final email = Email('invalid-email');
          userAdministrationService.validateUserEmail(
            email,
            onValid: () {
              fail('Expected email to be invalid, but it was validated as valid.');
            },
            onInvalid: (reason) {
              expect(reason, isA<EmailInvalidFormat>());
            },
          );
        });
      });
    });
  });
}
