import 'package:domain/services/user_administration/user_administration_service.dart';
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
    group('authorizeUpdateUserPassword', () {
      group('User', () {
        test('should authorize updating own password', () {
          final self = user;
          final result = userAdministrationService.authorizeUpdateUserPassword(
            initiator: self,
            target: self,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isTrue, reason: 'User should be able to update own password');
        });
        for (final other in [otherUser, admin, analyst]) {
          test('should not authorize updating ${other.role.name} password', () {
            final result = userAdministrationService.authorizeUpdateUserPassword(
              initiator: user,
              target: other,
              onAuthorized: () => true,
              onUnauthorized: (reason) => false,
            );
            expect(result, isFalse, reason: 'User should not be able to update ${other.role.name} password');
          });
        }
      });
      group('Admin', () {
        test('should authorize updating own password', () {
          final self = admin;
          final result = userAdministrationService.authorizeUpdateUserPassword(
            initiator: self,
            target: self,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isTrue, reason: 'Admin should be able to update own password');
        });
        for (final other in [user, otherAdmin]) {
          test('should authorize updating ${other.role.name} password', () {
            final result = userAdministrationService.authorizeUpdateUserPassword(
              initiator: admin,
              target: other,
              onAuthorized: () => true,
              onUnauthorized: (reason) => false,
            );
            expect(result, isTrue, reason: 'Admin should be able to update ${other.role.name} password');
          });
        }
        test('should not authorize updating analyst password', () {
          final result = userAdministrationService.authorizeUpdateUserPassword(
            initiator: admin,
            target: analyst,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isFalse, reason: 'Admin should not be able to update analyst password');
        });
      });
      group('Analyst', () {
        test('should authorize updating own password', () {
          final self = analyst;
          final result = userAdministrationService.authorizeUpdateUserPassword(
            initiator: self,
            target: self,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isTrue, reason: 'Analyst should be able to update own password');
        });
        for (final other in [user, admin, otherAnalyst]) {
          test('should authorize updating ${other.role.name} password', () {
            final result = userAdministrationService.authorizeUpdateUserPassword(
              initiator: analyst,
              target: other,
              onAuthorized: () => true,
              onUnauthorized: (reason) => false,
            );
            expect(result, isTrue, reason: 'Analyst should be able to update ${other.role.name} password');
          });
        }
      });
    });
  });
}
