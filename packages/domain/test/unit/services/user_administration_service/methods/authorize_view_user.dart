import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:test/test.dart';
import 'package:test_utils/mocks/mock_users.dart';
import '../../../utils/services/user_administration_service.dart';

/// Unit tests for [UserAdministrationService.authorizeViewUser].
void main() {
  late UserAdministrationService userAdministrationService;

  setUp(() {
    userAdministrationService = createTestUserAdministrationService(
        [mockUser, otherMockUser, mockAdmin, otherMockAdmin, mockAnalyst, otherMockAnalyst]);
  });

  group('UserAdministrationService', () {
    group('authorizeViewUser', () {
      group('User', () {
        test('should authorize viewing self', () {
          final self = mockUser;
          final result = userAdministrationService.authorizeViewUser(
            initiator: self,
            target: self,
            onAuthorized: () => true,
            onUnauthorized: (_) => false,
          );
          expect(result, isTrue, reason: 'User should be able to view self');
        });

        for (final target in [otherMockUser, mockAdmin]) {
          test('should authorize viewing ${target.role.name}', () {
            final result = userAdministrationService.authorizeViewUser(
              initiator: mockUser,
              target: target,
              onAuthorized: () => true,
              onUnauthorized: (_) => false,
            );
            expect(result, isTrue, reason: 'User should be able to view ${target.role.name}');
          });
        }

        test('should not authorize viewing analyst', () {
          final result = userAdministrationService.authorizeViewUser(
            initiator: mockUser,
            target: mockAnalyst,
            onAuthorized: () => true,
            onUnauthorized: (_) => false,
          );
          expect(result, isFalse, reason: 'User should not be able to view analyst');
        });
      });
      group('Admin', () {
        test('should authorize viewing self', () {
          final self = mockAdmin;
          final result = userAdministrationService.authorizeViewUser(
            initiator: self,
            target: self,
            onAuthorized: () => true,
            onUnauthorized: (_) => false,
          );
          expect(result, isTrue, reason: 'Admin should be able to view self');
        });

        for (final target in [mockUser, otherMockUser, otherMockAdmin]) {
          test('should authorize viewing ${target.role.name}', () {
            final result = userAdministrationService.authorizeViewUser(
              initiator: mockAdmin,
              target: target,
              onAuthorized: () => true,
              onUnauthorized: (_) => false,
            );
            expect(result, isTrue, reason: 'Admin should be able to view ${target.role.name}');
          });
        }

        test('should not authorize viewing analyst', () {
          final result = userAdministrationService.authorizeViewUser(
            initiator: mockAdmin,
            target: mockAnalyst,
            onAuthorized: () => true,
            onUnauthorized: (_) => false,
          );
          expect(result, isFalse, reason: 'Admin should not be able to view analyst');
        });
      });

      group('Analyst', () {
        test('should authorize viewing self', () {
          final self = mockAnalyst;
          final result = userAdministrationService.authorizeViewUser(
            initiator: self,
            target: self,
            onAuthorized: () => true,
            onUnauthorized: (_) => false,
          );
          expect(result, isTrue, reason: 'Analyst should be able to view self');
        });

        for (final target in [mockUser, mockAdmin, otherMockAnalyst]) {
          test('should authorize viewing ${target.role.name}', () {
            final result = userAdministrationService.authorizeViewUser(
              initiator: mockAnalyst,
              target: target,
              onAuthorized: () => true,
              onUnauthorized: (_) => false,
            );
            expect(result, isTrue, reason: 'Analyst should be able to view ${target.role.name}');
          });
        }
      });
    });
  });
}
