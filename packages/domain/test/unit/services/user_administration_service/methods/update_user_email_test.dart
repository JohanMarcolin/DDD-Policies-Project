import 'package:domain/policies/action_authorization_policies/user_administration/user_administration_policy.dart';
import 'package:domain/policies/policy_violation_exception.dart';
import 'package:domain/policies/value_validation_policies/user_credentials/user_credential_policy.dart';
import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:test_utils/domain/user_administration_service.dart';
import 'package:test_utils/mocks/mock_user_credentials.dart';
import 'package:test_utils/mocks/mock_user_repository.dart';
import 'package:test_utils/mocks/mock_users.dart';
import '../../../utils/services/user_administration_service.dart';

void main() {
  late UserAdministrationService userAdministrationService;

  setUp(() {
    userAdministrationService = createTestUserAdministrationService(
        [mockUser, otherMockUser, mockAdmin, otherMockAdmin, mockAnalyst, otherMockAnalyst]);
  });

  group('UserAdministrationService', () {
    group('updateUserEmail', () {
      group('User', () {
        test('should be able to update own email to a new valid email', () async {
          final self = mockUser;
          final newEmail = mockValidEmail;
          await userAdministrationService.updateUserEmail(initiator: self, target: self, newEmail: newEmail);
          final updatedUser = await userAdministrationService.viewUser(initiator: self, userId: self.userId);
          expect(updatedUser!.email, equals(newEmail),
              reason: 'User should be able to update own email to valid email');
        });

        test('should not be able to update own email to an invalid email', () async {
          final self = mockUser;
          final newEmail = mockInvalidEmail;
          expect(
            () async =>
                await userAdministrationService.updateUserEmail(initiator: self, target: self, newEmail: newEmail),
            throwsA(
              predicate((e) => e is PolicyViolationException<EmailInvalidReason> && e.reason is EmailInvalidFormat),
            ),
            reason: 'User should not be able to update own email to invalid email',
          );
        });

        for (final other in [otherMockUser, mockAdmin, mockAnalyst]) {
          test('should not be able to update email of ${other.role.name}', () async {
            final newEmail = mockValidEmail;
            expect(
              () async => await userAdministrationService.updateUserEmail(
                  initiator: mockUser, target: other, newEmail: newEmail),
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
          final self = mockAdmin;
          final newEmail = mockValidEmail;
          await userAdministrationService.updateUserEmail(initiator: self, target: self, newEmail: newEmail);
          final updatedUser = await userAdministrationService.viewUser(initiator: self, userId: self.userId);
          expect(updatedUser!.email, equals(newEmail),
              reason: 'Admin should be able to update own email to valid email');
        });

        test('should not be able to update own email to an invalid email', () async {
          final self = mockAdmin;
          final newEmail = mockInvalidEmail;
          expect(
            () async =>
                await userAdministrationService.updateUserEmail(initiator: self, target: self, newEmail: newEmail),
            throwsA(
              predicate((e) => e is PolicyViolationException<EmailInvalidReason> && e.reason is EmailInvalidFormat),
            ),
            reason: 'Admin should not be able to update own email to invalid email',
          );
        });

        for (final other in [mockUser, otherMockAdmin]) {
          test('should be able to update email of ${other.role.name} to a new valid email', () async {
            final self = mockAdmin;
            final newEmail = mockValidEmail;
            await userAdministrationService.updateUserEmail(initiator: self, target: other, newEmail: newEmail);
            final updatedUser = await userAdministrationService.viewUser(initiator: self, userId: other.userId);
            expect(updatedUser!.email, equals(newEmail),
                reason: 'Admin should be able to update email of ${other.role.name} to valid email');
          });
        }

        test('should not be able to update analyst email', () async {
          final self = mockAdmin;
          final newEmail = mockValidEmail;
          expect(
            () async => await userAdministrationService.updateUserEmail(
                initiator: self, target: mockAnalyst, newEmail: newEmail),
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
          final self = mockAnalyst;
          final newEmail = mockValidEmail;
          await userAdministrationService.updateUserEmail(initiator: self, target: self, newEmail: newEmail);
          final updatedUser = await userAdministrationService.viewUser(initiator: self, userId: self.userId);
          expect(updatedUser!.email, equals(newEmail),
              reason: 'Analyst should be able to update own email to valid email');
        });

        test('should not be able to update own email to an invalid email', () async {
          final self = mockAnalyst;
          final newEmail = mockInvalidEmail;
          expect(
            () async =>
                await userAdministrationService.updateUserEmail(initiator: self, target: self, newEmail: newEmail),
            throwsA(
              predicate((e) => e is PolicyViolationException<EmailInvalidReason> && e.reason is EmailInvalidFormat),
            ),
            reason: 'Analyst should not be able to update own email to invalid email',
          );
        });

        for (final other in [mockUser, mockAdmin, otherMockAnalyst]) {
          test('should be able to update email of ${other.role.name} to a new valid email', () async {
            final newEmail = mockValidEmail;
            await userAdministrationService.updateUserEmail(initiator: mockAnalyst, target: other, newEmail: newEmail);
            final updatedUser = await userAdministrationService.viewUser(initiator: mockAnalyst, userId: other.userId);
            expect(updatedUser!.email, equals(newEmail),
                reason: 'Analyst should be able to update email of ${other.role.name} to valid email');
          });
        }
      });

      test('should pass a failed repository update on to the caller', () async {
        final mockUserRepository = MockUserRepository();
        final failure = Exception('update email failed');
        when(() => mockUserRepository.updateEmail(userId: mockUser.userId, newEmail: mockValidEmail))
            .thenAnswer((_) async => throw failure);
        final service = createStubbedUserAdministrationService(mockUserRepository);

        expect(
          () async => await service.updateUserEmail(initiator: mockUser, target: mockUser, newEmail: mockValidEmail),
          throwsA(same(failure)),
          reason: 'A failed repository update should reach the caller',
        );
      });
    });
  });
}
