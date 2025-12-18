import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:test/test.dart';
import 'package:test_utils/mocks/mock_users.dart';
import '../../../utils/services/user_administration_service.dart';

/// Unit tests for [UserAdministrationService.authorizeUpdateUserPassword].
void main() {
  late UserAdministrationService userAdministrationService;

  setUp(() {
    userAdministrationService = createTestUserAdministrationService(
        [mockUser, otherMockUser, mockAdmin, otherMockAdmin, mockAnalyst, otherMockAnalyst]);
  });

  group('UserAdministrationService', () {
    group('authorizeUpdateUserPassword', () {
      group('User', () {
        test('should authorize updating own password', () {
          final self = mockUser;
          final result = userAdministrationService.authorizeUpdateUserPassword(
            initiator: self,
            target: self,
            onAuthorized: () => true,
            onUnauthorized: (_) => false,
          );
          expect(result, isTrue, reason: 'User should be able to update own password');
        });

        for (final other in [otherMockUser, mockAdmin, mockAnalyst]) {
          test('should not authorize updating ${other.role.name} password', () {
            final result = userAdministrationService.authorizeUpdateUserPassword(
              initiator: mockUser,
              target: other,
              onAuthorized: () => true,
              onUnauthorized: (_) => false,
            );
            expect(result, isFalse, reason: 'User should not be able to update ${other.role.name} password');
          });
        }
      });
      group('Admin', () {
        test('should authorize updating own password', () {
          final self = mockAdmin;
          final result = userAdministrationService.authorizeUpdateUserPassword(
            initiator: self,
            target: self,
            onAuthorized: () => true,
            onUnauthorized: (_) => false,
          );
          expect(result, isTrue, reason: 'Admin should be able to update own password');
        });

        for (final other in [mockUser, otherMockAdmin]) {
          test('should authorize updating ${other.role.name} password', () {
            final result = userAdministrationService.authorizeUpdateUserPassword(
              initiator: mockAdmin,
              target: other,
              onAuthorized: () => true,
              onUnauthorized: (_) => false,
            );
            expect(result, isTrue, reason: 'Admin should be able to update ${other.role.name} password');
          });
        }

        test('should not authorize updating analyst password', () {
          final result = userAdministrationService.authorizeUpdateUserPassword(
            initiator: mockAdmin,
            target: mockAnalyst,
            onAuthorized: () => true,
            onUnauthorized: (_) => false,
          );
          expect(result, isFalse, reason: 'Admin should not be able to update analyst password');
        });
      });
      group('Analyst', () {
        test('should authorize updating own password', () {
          final self = mockAnalyst;
          final result = userAdministrationService.authorizeUpdateUserPassword(
            initiator: self,
            target: self,
            onAuthorized: () => true,
            onUnauthorized: (_) => false,
          );
          expect(result, isTrue, reason: 'Analyst should be able to update own password');
        });

        for (final other in [mockUser, mockAdmin, otherMockAnalyst]) {
          test('should authorize updating ${other.role.name} password', () {
            final result = userAdministrationService.authorizeUpdateUserPassword(
              initiator: mockAnalyst,
              target: other,
              onAuthorized: () => true,
              onUnauthorized: (_) => false,
            );
            expect(result, isTrue, reason: 'Analyst should be able to update ${other.role.name} password');
          });
        }
      });
    });
  });
}
