import 'package:domain/policies/action_authorization_policies/user_administration/user_administration_policy.dart';
import 'package:domain/policies/policy_violation_exception.dart';
import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:test/test.dart';
import 'package:test_utils/mocks/mock_users.dart';
import '../../../utils/services/user_administration_service.dart';

/// Unit tests for [UserAdministrationService.deleteUser].
void main() {
  late UserAdministrationService userAdministrationService;

  setUp(() {
    userAdministrationService = createTestUserAdministrationService(
        [mockUser, otherMockUser, mockAdmin, otherMockAdmin, mockAnalyst, otherMockAnalyst]);
  });

  group('UserAdministrationService', () {
    group('deleteUser', () {
      group('User', () {
        test('should be able to delete self', () async {
          final self = mockUser;
          await userAdministrationService.deleteUser(initiator: self, target: self);
          final users = await userAdministrationService.viewUsers(initiator: self);
          expect(users, isNot(contains(self)), reason: 'User should be able to delete self');
        });

        for (final other in [otherMockUser, mockAdmin, mockAnalyst]) {
          test('should not be able to delete ${other.role.name}', () async {
            expect(
                () async => await userAdministrationService.deleteUser(initiator: mockUser, target: other),
                throwsA(
                  predicate((e) =>
                      e is PolicyViolationException<DeleteUserUnauthorizedReason> && e.reason == CanOnlyDeleteSelf()),
                ),
                reason: 'User should only be able to delete self');
          });
        }
      });
      group('Admin', () {
        test('should be able to delete self', () async {
          final self = mockAdmin;
          await userAdministrationService.deleteUser(initiator: self, target: self);
          final users = await userAdministrationService.viewUsers(initiator: self);
          expect(users, isNot(contains(self)), reason: 'Admin should be able to delete self');
        });

        for (final other in [mockUser, otherMockAdmin]) {
          test('should be able to delete ${other.role.name}', () async {
            await userAdministrationService.deleteUser(initiator: mockAdmin, target: other);
            final users = await userAdministrationService.viewUsers(initiator: mockAdmin);
            expect(users, isNot(contains(other)), reason: 'Admin should be able to delete ${other.role.name}');
          });
        }

        test('should not be able to delete analyst', () async {
          expect(
              () async => await userAdministrationService.deleteUser(initiator: mockAdmin, target: mockAnalyst),
              throwsA(
                predicate((e) =>
                    e is PolicyViolationException<DeleteUserUnauthorizedReason> && e.reason == CannotDeleteAnalyst()),
              ),
              reason: 'Admin should not be able to delete analyst');
        });
      });
      group('Analyst', () {
        test('should not be able to delete self', () async {
          expect(
              () async => await userAdministrationService.deleteUser(initiator: mockAnalyst, target: mockAnalyst),
              throwsA(
                predicate(
                  (e) => e is PolicyViolationException<DeleteUserUnauthorizedReason> && e.reason == CannotDeleteSelf(),
                ),
              ),
              reason: 'Analyst should not be able to delete self');
        });

        for (final other in [mockUser, mockAdmin, otherMockAnalyst]) {
          test('should be able to delete ${other.role.name}', () async {
            await userAdministrationService.deleteUser(initiator: mockAnalyst, target: other);
            final users = await userAdministrationService.viewUsers(initiator: mockAnalyst);
            expect(users, isNot(contains(other)), reason: 'Analyst should be able to delete ${other.role.name}');
          });
        }
      });
    });
  });
}
