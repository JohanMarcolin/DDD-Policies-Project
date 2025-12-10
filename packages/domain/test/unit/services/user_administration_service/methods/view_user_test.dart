import 'package:domain/policies/action_authorization_policies/user_administration/user_administration_policy.dart';
import 'package:domain/policies/policy_violation_exception.dart';
import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:test/test.dart';
import 'package:test_utils/mocks/mock_users.dart';
import '../../../utils/services/user_administration_service.dart';

void main() {
  late UserAdministrationService userAdministrationService;

  setUp(() {
    userAdministrationService = createTestUserAdministrationService(
        [mockUser, otherMockUser, mockAdmin, otherMockAdmin, mockAnalyst, otherMockAnalyst]);
  });

  group('UserAdministrationService', () {
    group('viewUser', () {
      group('User', () {
        test('should be able to view self', () async {
          final self = mockUser;
          final viewedUser = await userAdministrationService.viewUser(initiator: self, userId: self.userId);
          expect(viewedUser, equals(self), reason: 'User should be able to view self');
        });
        for (final other in [otherMockUser, mockAdmin]) {
          test('should be able to view ${other.role.name}', () async {
            final viewedUser = await userAdministrationService.viewUser(initiator: mockUser, userId: other.userId);
            expect(viewedUser, equals(other), reason: 'User should be able to view ${other.role.name}');
          });
        }
        test('should not be able to view analyst', () async {
          expect(
            () async => await userAdministrationService.viewUser(initiator: mockUser, userId: mockAnalyst.userId),
            throwsA(
              predicate(
                  (e) => e is PolicyViolationException<ViewUserUnauthorizedReason> && e.reason == CannotViewAnalyst()),
            ),
            reason: 'User should not be able to view analyst',
          );
        });
      });
      group('Admin', () {
        test('should be able to view self', () async {
          final self = mockAdmin;
          final viewedUser = await userAdministrationService.viewUser(initiator: self, userId: self.userId);
          expect(viewedUser, equals(self), reason: 'Admin should be able to view self');
        });
        for (final other in [mockUser, otherMockAdmin]) {
          test('should be able to view ${other.role.name}', () async {
            final viewedUser = await userAdministrationService.viewUser(initiator: mockAdmin, userId: other.userId);
            expect(viewedUser, equals(other), reason: 'Admin should be able to view ${other.role.name}');
          });
        }
        test('should not be able to view analyst', () async {
          expect(
            () async => await userAdministrationService.viewUser(initiator: mockAdmin, userId: mockAnalyst.userId),
            throwsA(
              predicate(
                  (e) => e is PolicyViolationException<ViewUserUnauthorizedReason> && e.reason == CannotViewAnalyst()),
            ),
            reason: 'Admin should not be able to view analyst',
          );
        });
      });
      group('Analyst', () {
        test('should be able to view self', () async {
          final self = mockAnalyst;
          final viewedUser = await userAdministrationService.viewUser(initiator: self, userId: self.userId);
          expect(viewedUser, equals(self), reason: 'Analyst should be able to view self');
        });
        for (final other in [mockUser, mockAdmin, otherMockAnalyst]) {
          test('should be able to view ${other.role.name}', () async {
            final viewedUser = await userAdministrationService.viewUser(initiator: mockAnalyst, userId: other.userId);
            expect(viewedUser, equals(other), reason: 'Analyst should be able to view ${other.role.name}');
          });
        }
      });
    });
  });
}
