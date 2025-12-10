import 'package:domain/policies/action_authorization_policies/user_administration/user_administration_policy.dart';
import 'package:domain/policies/policy_violation_exception.dart';
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
    group('updateUserPassword', () {
      group('User', () {
        test('should be able to update own password to a new valid password', () async {
          final self = user;
          final newPassword = Password('NewPassword123!');
          await userAdministrationService.updateUserPassword(initiator: self, target: self, newPassword: newPassword);
          // No direct way to verify password, but no exception means success
        });
        test('should not be able to update own password to an invalid password', () async {
          final self = user;
          final newPassword = Password('short');
          expect(
            () async => await userAdministrationService.updateUserPassword(
                initiator: self, target: self, newPassword: newPassword),
            throwsA(
              predicate((e) =>
                  e is PolicyViolationException<UpdateUserPasswordUnauthorizedReason> && e.reason is PasswordTooShort),
            ),
            reason: 'User should not be able to update own password to invalid password',
          );
        });
        for (final other in [otherUser, otherAdmin, analyst]) {
          test('should not be able to update password of ${other.role.name}', () async {
            final newPassword = Password('NewPassword123!');
            expect(
              () async => await userAdministrationService.updateUserPassword(
                  initiator: user, target: other, newPassword: newPassword),
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
          final self = admin;
          final newPassword = Password('NewPassword123!');
          await userAdministrationService.updateUserPassword(initiator: self, target: self, newPassword: newPassword);
        });
        test('should not be able to update own password to an invalid password', () async {
          final self = admin;
          final newPassword = Password('short');
          expect(
            () async => await userAdministrationService.updateUserPassword(
                initiator: self, target: self, newPassword: newPassword),
            throwsA(
              predicate((e) =>
                  e is PolicyViolationException<UpdateUserPasswordUnauthorizedReason> && e.reason is PasswordTooShort),
            ),
            reason: 'Admin should not be able to update own password to invalid password',
          );
        });
        for (final other in [otherUser, user]) {
          test('should be able to update password of ${other.role.name} to a new valid password', () async {
            final self = admin;
            final newPassword = Password('NewPassword123!');
            await userAdministrationService.updateUserPassword(
                initiator: self, target: other, newPassword: newPassword);
          });
        }
        test('should not be able to update analyst password', () async {
          final self = admin;
          final newPassword = Password('NewPassword123!');
          expect(
            () async => await userAdministrationService.updateUserPassword(
                initiator: self, target: analyst, newPassword: newPassword),
            throwsA(
              predicate((e) =>
                  e is PolicyViolationException<UpdateUserPasswordUnauthorizedReason> &&
                  e.reason is CanOnlyUpdatePasswordOnSelf),
            ),
            reason: 'Admin should not be able to update analyst password',
          );
        });
      });
      group('Analyst', () {
        test('should be able to update own password to a new valid password', () async {
          final self = analyst;
          final newPassword = Password('NewPassword123!');
          await userAdministrationService.updateUserPassword(initiator: self, target: self, newPassword: newPassword);
        });
        test('should not be able to update own password to an invalid password', () async {
          final self = analyst;
          final newPassword = Password('short');
          expect(
            () async => await userAdministrationService.updateUserPassword(
                initiator: self, target: self, newPassword: newPassword),
            throwsA(
              predicate((e) =>
                  e is PolicyViolationException<UpdateUserPasswordUnauthorizedReason> && e.reason is PasswordTooShort),
            ),
            reason: 'Analyst should not be able to update own password to invalid password',
          );
        });
        for (final other in [otherUser, otherAdmin]) {
          test('should be able to update password of ${other.role.name} to a new valid password', () async {
            final self = analyst;
            final newPassword = Password('NewPassword123!');
            await userAdministrationService.updateUserPassword(
                initiator: self, target: other, newPassword: newPassword);
          });
        }
      });
    });
  });
}
