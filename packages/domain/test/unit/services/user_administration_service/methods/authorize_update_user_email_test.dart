import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:test/test.dart';
import 'package:test_utils/mocks/mock_users.dart';
import '../../../utils/services/user_administration_service.dart';

/// Unit tests for [UserAdministrationService.authorizeUpdateUserEmail].
void main() {
  late UserAdministrationService userAdministrationService;

  setUp(() {
    userAdministrationService = createTestUserAdministrationService(
        [mockUser, otherMockUser, mockAdmin, otherMockAdmin, mockAnalyst, otherMockAnalyst]);
  });

  group('UserAdministrationService', () {
    group('authorizeUpdateUserEmail', () {
      group('User', () {
        test('should authorize updating own email', () {
          final self = mockUser;
          final result = userAdministrationService.authorizeUpdateUserEmail(
            initiator: self,
            target: self,
            onAuthorized: () => true,
            onUnauthorized: (_) => false,
          );
          expect(result, isTrue, reason: 'User should be able to update own email');
        });

        for (final other in [otherMockUser, mockAdmin, mockAnalyst]) {
          test('should not authorize updating ${other.role.name} email', () {
            final result = userAdministrationService.authorizeUpdateUserEmail(
              initiator: mockUser,
              target: other,
              onAuthorized: () => true,
              onUnauthorized: (_) => false,
            );
            expect(result, isFalse, reason: 'User should not be able to update ${other.role.name} email');
          });
        }
      });
      group('Admin', () {
        test('should authorize updating own email', () {
          final self = mockAdmin;
          final result = userAdministrationService.authorizeUpdateUserEmail(
            initiator: self,
            target: self,
            onAuthorized: () => true,
            onUnauthorized: (_) => false,
          );
          expect(result, isTrue, reason: 'Admin should be able to update own email');
        });

        for (final other in [otherMockAdmin, mockUser]) {
          test('should authorize updating ${other.role.name} email', () {
            final result = userAdministrationService.authorizeUpdateUserEmail(
              initiator: mockAdmin,
              target: other,
              onAuthorized: () => true,
              onUnauthorized: (_) => false,
            );
            expect(result, isTrue, reason: 'Admin should be able to update ${other.role.name} email');
          });
        }

        test('should not authorize updating analyst email', () {
          final result = userAdministrationService.authorizeUpdateUserEmail(
            initiator: mockAdmin,
            target: mockAnalyst,
            onAuthorized: () => true,
            onUnauthorized: (_) => false,
          );
          expect(result, isFalse, reason: 'Admin should not be able to update analyst email');
        });
      });
      group('Analyst', () {
        test('should authorize updating own email', () {
          final self = mockAnalyst;
          final result = userAdministrationService.authorizeUpdateUserEmail(
            initiator: self,
            target: self,
            onAuthorized: () => true,
            onUnauthorized: (_) => false,
          );
          expect(result, isTrue, reason: 'Analyst should be able to update own email');
        });

        for (final other in [mockUser, mockAdmin, otherMockAnalyst]) {
          test('should authorize updating ${other.role.name} email', () {
            final result = userAdministrationService.authorizeUpdateUserEmail(
              initiator: mockAnalyst,
              target: other,
              onAuthorized: () => true,
              onUnauthorized: (_) => false,
            );
            expect(result, isTrue, reason: 'Analyst should be able to update ${other.role.name} email');
          });
        }
      });
    });
  });
}
