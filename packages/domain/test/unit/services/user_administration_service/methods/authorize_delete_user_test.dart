import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:test/test.dart';
import 'package:test_utils/mocks/mock_users.dart';
import '../../../utils/services/user_administration_service.dart';

/// Unit tests for [UserAdministrationService.authorizeDeleteUser].
void main() {
  late UserAdministrationService userAdministrationService;

  setUp(() {
    userAdministrationService = createTestUserAdministrationService(
        [mockUser, otherMockUser, mockAdmin, otherMockAdmin, mockAnalyst, otherMockAnalyst]);
  });

  group('UserAdministrationService', () {
    group('authorizeDeleteUser', () {
      group('User', () {
        test('should authorize deleting self', () {
          final self = mockUser;
          final result = userAdministrationService.authorizeDeleteUser(
            initiator: self,
            target: self,
            onAuthorized: () => true,
            onUnauthorized: (_) => false,
          );
          expect(result, isTrue, reason: 'Users should be able to delete themselves');
        });

        for (final other in [otherMockUser, mockAdmin, mockAnalyst]) {
          test('should not authorize deleting ${other.role.name}', () {
            final result = userAdministrationService.authorizeDeleteUser(
              initiator: mockUser,
              target: other,
              onAuthorized: () => true,
              onUnauthorized: (_) => false,
            );
            expect(result, isFalse, reason: 'Users should not be able to delete ${other.role.name}');
          });
        }
      });
      group('Admin', () {
        test('should authorize deleting self', () {
          final self = mockAdmin;
          final result = userAdministrationService.authorizeDeleteUser(
            initiator: self,
            target: self,
            onAuthorized: () => true,
            onUnauthorized: (_) => false,
          );
          expect(result, isTrue, reason: 'Admins should be able to delete themselves');
        });

        for (final other in [mockUser, otherMockAdmin]) {
          test('should authorize deleting ${other.role.name}', () {
            final result = userAdministrationService.authorizeDeleteUser(
              initiator: mockAdmin,
              target: other,
              onAuthorized: () => true,
              onUnauthorized: (_) => false,
            );
            expect(result, isTrue, reason: 'Admins should be able to delete ${other.role.name}');
          });
        }

        test('should not authorize deleting analysts', () {
          final result = userAdministrationService.authorizeDeleteUser(
            initiator: mockAdmin,
            target: mockAnalyst,
            onAuthorized: () => true,
            onUnauthorized: (_) => false,
          );
          expect(result, isFalse, reason: 'Admins should not be able to delete Analysts');
        });
      });
      group('Analyst', () {
        test('should not authorize deleting self', () {
          final self = mockAnalyst;
          final result = userAdministrationService.authorizeDeleteUser(
            initiator: self,
            target: self,
            onAuthorized: () => true,
            onUnauthorized: (_) => false,
          );
          expect(result, isFalse, reason: 'Analysts should not be able to delete themselves');
        });
        for (final other in [mockUser, mockAdmin, otherMockAnalyst]) {
          test('should authorize deleting ${other.role.name}', () {
            final result = userAdministrationService.authorizeDeleteUser(
              initiator: mockAnalyst,
              target: other,
              onAuthorized: () => true,
              onUnauthorized: (_) => false,
            );
            expect(result, isTrue, reason: 'Analysts should be able to delete ${other.role.name}');
          });
        }
      });
    });
  });
}
