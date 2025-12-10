import 'package:domain/policies/action_authorization_policies/user_administration/user_administration_policy.dart';
import 'package:domain/policies/policy_violation_exception.dart';
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
    group('updateUserEmail', () {
      group('User', () {
        test('should be able to update own email to a new valid email', () async {
          final self = user;
          final newEmail = Email('new.email@example.com');
          await userAdministrationService.updateUserEmail(initiator: self, target: self, newEmail: newEmail);
          final updatedUser = await userAdministrationService.viewUser(initiator: self, userId: self.userId);
          expect(updatedUser!.email, equals(newEmail),
              reason: 'User should be able to update own email to valid email');
        });
        test('should not be able to update own email to an invalid email', () async {
          final self = user;
          final newEmail = Email('invalid-email');
          expect(
            () async =>
                await userAdministrationService.updateUserEmail(initiator: self, target: self, newEmail: newEmail),
            throwsA(
              predicate((e) => e is PolicyViolationException<EmailInvalidReason> && e.reason is EmailInvalidFormat),
            ),
            reason: 'User should not be able to update own email to invalid email',
          );
        });
        for (final other in [otherUser, otherAdmin, analyst]) {
          test('should not be able to update email of ${other.role.name}', () async {
            final newEmail = Email('new.email@example.com');
            expect(
              () async =>
                  await userAdministrationService.updateUserEmail(initiator: user, target: other, newEmail: newEmail),
              throwsA(
                predicate((e) =>
                    e is PolicyViolationException<UpdateUserEmailUnauthorizedReason> &&
                    e.reason is CanOnlyUpdateEmailOnSelf),
              ),
              reason: 'User should only be able to update own email',
            );
          });
        }
      });
      group('Admin', () {
        test('should be able to update own email to a new valid email', () async {
          final self = admin;
          final newEmail = Email('new.email@example.com');
          await userAdministrationService.updateUserEmail(initiator: self, target: self, newEmail: newEmail);
          final updatedUser = await userAdministrationService.viewUser(initiator: self, userId: self.userId);
          expect(updatedUser!.email, equals(newEmail),
              reason: 'Admin should be able to update own email to valid email');
        });
        test('should not be able to update own email to an invalid email', () async {
          final self = admin;
          final newEmail = Email('invalid-email');
          expect(
            () async =>
                await userAdministrationService.updateUserEmail(initiator: self, target: self, newEmail: newEmail),
            throwsA(
              predicate((e) => e is PolicyViolationException<EmailInvalidReason> && e.reason is EmailInvalidFormat),
            ),
            reason: 'Admin should not be able to update own email to invalid email',
          );
        });
        for (final other in [otherUser, user]) {
          test('should be able to update email of ${other.role.name} to a new valid email', () async {
            final self = admin;
            final newEmail = Email('new.email@example.com');
            await userAdministrationService.updateUserEmail(initiator: self, target: other, newEmail: newEmail);
            final updatedUser = await userAdministrationService.viewUser(initiator: self, userId: other.userId);
            expect(updatedUser!.email, equals(newEmail),
                reason: 'Admin should be able to update email of ${other.role.name} to valid email');
          });
        }
        test('should not be able to update analyst email', () async {
          final self = admin;
          final newEmail = Email('new.email@example.com');
          expect(
            () async =>
                await userAdministrationService.updateUserEmail(initiator: self, target: analyst, newEmail: newEmail),
            throwsA(
              predicate((e) =>
                  e is PolicyViolationException<UpdateUserEmailUnauthorizedReason> &&
                  e.reason is CannotUpdateEmailOnAnalyst),
            ),
            reason: 'Admin should not be able to update analyst email',
          );
        });
      });
      group('Analyst', () {
        test('should be able to update own email to a new valid email', () async {
          final self = analyst;
          final newEmail = Email('new.email@example.com');
          await userAdministrationService.updateUserEmail(initiator: self, target: self, newEmail: newEmail);
          final updatedUser = await userAdministrationService.viewUser(initiator: self, userId: self.userId);
          expect(updatedUser!.email, equals(newEmail),
              reason: 'Analyst should be able to update own email to valid email');
        });
        test('should not be able to update own email to an invalid email', () async {
          final self = analyst;
          final newEmail = Email('invalid-email');
          expect(
            () async =>
                await userAdministrationService.updateUserEmail(initiator: self, target: self, newEmail: newEmail),
            throwsA(
              predicate((e) => e is PolicyViolationException<EmailInvalidReason> && e.reason is EmailInvalidFormat),
            ),
            reason: 'Analyst should not be able to update own email to invalid email',
          );
        });
        for (final other in [otherUser, otherAdmin]) {
          test('should be able to update email of ${other.role.name} to a new valid email', () async {
            final self = analyst;
            final newEmail = Email('new.email@example.com');
            await userAdministrationService.updateUserEmail(initiator: self, target: other, newEmail: newEmail);
            final updatedUser = await userAdministrationService.viewUser(initiator: self, userId: other.userId);
            expect(updatedUser!.email, equals(newEmail),
                reason: 'Analyst should be able to update email of ${other.role.name} to valid email');
          });
        }
      });
    });
  });
}
