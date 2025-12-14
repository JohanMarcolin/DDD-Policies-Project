import 'package:domain/policies/action_authorization_policies/user_administration/user_administration_policy.dart';
import 'package:domain/policies/policy_violation_exception.dart';
import 'package:domain/policies/value_validation_policies/user_credentials/user_credential_policy.dart';
import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:test/test.dart';
import 'package:test_utils/mocks/mock_user_credentials.dart';
import 'package:test_utils/mocks/mock_users.dart';
import '../../../utils/services/user_administration_service.dart';

/// Unit tests for [UserAdministrationService.updateUserPassword].
void main() {
  late UserAdministrationService userAdministrationService;

  setUp(() {
    userAdministrationService = createTestUserAdministrationService(
        [mockUser, otherMockUser, mockAdmin, otherMockAdmin, mockAnalyst, otherMockAnalyst]);
  });

  group('UserAdministrationService', () {
    group('updateUserPassword', () {
      group('User', () {
        test('should be able to update own password to a new valid password', () async {
          final self = mockUser;
          final newPassword = mockValidPassword;

          expect(
            () async => await userAdministrationService.updateUserPassword(
              initiator: self,
              target: self,
              newPassword: newPassword,
            ),
            returnsNormally,
            reason: 'User should be able to update their own password to a valid password.',
          );
        });

        for (final invalidPassword in mockInvalidPasswords) {
          test('should not be able to update own password to an invalid password', () async {
            final self = mockUser;
            final newPassword = invalidPassword;
            expect(
              () async => await userAdministrationService.updateUserPassword(
                  initiator: self, target: self, newPassword: newPassword),
              throwsA(predicate((e) => e is PolicyViolationException<PasswordInvalidReason>)),
              reason:
                  'User should not be able to update own password to invalid password of value "${newPassword.value}"',
            );
          });
        }

        for (final other in [otherMockUser, otherMockAdmin, mockAnalyst]) {
          test('should not be able to update password of ${other.role.name}', () async {
            final newPassword = mockValidPassword;
            expect(
              () async => await userAdministrationService.updateUserPassword(
                  initiator: mockUser, target: other, newPassword: newPassword),
              throwsA(
                predicate((e) =>
                    e is PolicyViolationException<UpdateUserPasswordUnauthorizedReason> &&
                    e.reason is CanOnlyUpdatePasswordOnSelf),
              ),
              reason: 'User should only be able to update own password',
            );
          });
        }
      });
      group('Admin', () {
        test('should be able to update own password to a new valid password', () async {
          final self = mockAdmin;
          final newPassword = mockValidPassword;

          expect(
            () async => await userAdministrationService.updateUserPassword(
              initiator: self,
              target: self,
              newPassword: newPassword,
            ),
            returnsNormally,
            reason: 'Admin should be able to update their own password to a valid password.',
          );
        });

        for (final invalidPassword in mockInvalidPasswords) {
          test('should not be able to update own password to an invalid password', () async {
            final self = mockAdmin;
            final newPassword = invalidPassword;
            expect(
              () async => await userAdministrationService.updateUserPassword(
                  initiator: self, target: self, newPassword: newPassword),
              throwsA(predicate((e) => e is PolicyViolationException<PasswordInvalidReason>)),
              reason:
                  'Admin should not be able to update own password to invalid password of value "${newPassword.value}"',
            );
          });
        }

        for (final other in [otherMockUser, mockUser]) {
          test('should be able to update password of ${other.role.name} to a new valid password', () async {
            final self = mockAdmin;
            final newPassword = mockValidPassword;

            expect(
              () async => await userAdministrationService.updateUserPassword(
                initiator: self,
                target: other,
                newPassword: newPassword,
              ),
              returnsNormally,
              reason: 'Admin should be able to update the password of ${other.role.name} to a valid password.',
            );
          });
        }
        test('should not be able to update analyst password', () async {
          final self = mockAdmin;
          final newPassword = mockValidPassword;
          expect(
            () async => await userAdministrationService.updateUserPassword(
                initiator: self, target: mockAnalyst, newPassword: newPassword),
            throwsA(
              predicate((e) =>
                  e is PolicyViolationException<UpdateUserPasswordUnauthorizedReason> &&
                  e.reason is CannotUpdatePasswordOnAnalyst),
            ),
            reason: 'Admin should not be able to update analyst password',
          );
        });
      });
      group('Analyst', () {
        test('should be able to update own password to a new valid password', () async {
          final self = mockAnalyst;
          final newPassword = mockValidPassword;

          expect(
            () async => await userAdministrationService.updateUserPassword(
              initiator: self,
              target: self,
              newPassword: newPassword,
            ),
            returnsNormally,
            reason: 'Analyst should be able to update their own password to a valid password.',
          );
        });

        for (final invalidPassword in mockInvalidPasswords) {
          test('should not be able to update own password to an invalid password', () async {
            final self = mockAnalyst;
            final newPassword = invalidPassword;
            expect(
              () async => await userAdministrationService.updateUserPassword(
                  initiator: self, target: self, newPassword: newPassword),
              throwsA(predicate((e) => e is PolicyViolationException<PasswordInvalidReason>)),
              reason:
                  'Analyst should not be able to update own password to invalid password of value "${newPassword.value}"',
            );
          });
        }

        for (final other in [otherMockUser, otherMockAdmin]) {
          test('should be able to update password of ${other.role.name} to a new valid password', () async {
            final self = mockAnalyst;
            final newPassword = mockValidPassword;

            expect(
              () async => await userAdministrationService.updateUserPassword(
                initiator: self,
                target: other,
                newPassword: newPassword,
              ),
              returnsNormally,
              reason: 'Analyst should be able to update the password of ${other.role.name} to a valid password.',
            );
          });
        }
      });
    });
  });
}
