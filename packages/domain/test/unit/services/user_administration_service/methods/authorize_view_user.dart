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
    group('authorizeViewUser', () {
      group('User', () {
        test('should authorize viewing self', () {
          final self = user;
          final result = userAdministrationService.authorizeViewUser(
            initiator: self,
            target: self,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isTrue, reason: 'User should be able to view self');
        });
        for (final target in [otherUser, admin]) {
          test('should authorize viewing ${target.role.name}', () {
            final result = userAdministrationService.authorizeViewUser(
              initiator: user,
              target: target,
              onAuthorized: () => true,
              onUnauthorized: (reason) => false,
            );
            expect(result, isTrue, reason: 'User should be able to view ${target.role.name}');
          });
        }
        test('should not authorize viewing analyst', () {
          final result = userAdministrationService.authorizeViewUser(
            initiator: user,
            target: analyst,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isFalse, reason: 'User should not be able to view analyst');
        });
      });
      group('Admin', () {
        test('should authorize viewing self', () {
          final self = admin;
          final result = userAdministrationService.authorizeViewUser(
            initiator: self,
            target: self,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isTrue, reason: 'Admin should be able to view self');
        });
        for (final target in [user, otherUser, otherAdmin]) {
          test('should authorize viewing ${target.role.name}', () {
            final result = userAdministrationService.authorizeViewUser(
              initiator: admin,
              target: target,
              onAuthorized: () => true,
              onUnauthorized: (reason) => false,
            );
            expect(result, isTrue, reason: 'Admin should be able to view ${target.role.name}');
          });
        }
        test('should not authorize viewing analyst', () {
          final result = userAdministrationService.authorizeViewUser(
            initiator: admin,
            target: analyst,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isFalse, reason: 'Admin should not be able to view analyst');
        });
      });
      group('Analyst', () {
        test('should authorize viewing self', () {
          final self = analyst;
          final result = userAdministrationService.authorizeViewUser(
            initiator: self,
            target: self,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isTrue, reason: 'Analyst should be able to view self');
        });
        for (final target in [user, admin, otherAnalyst]) {
          test('should authorize viewing ${target.role.name}', () {
            final result = userAdministrationService.authorizeViewUser(
              initiator: analyst,
              target: target,
              onAuthorized: () => true,
              onUnauthorized: (reason) => false,
            );
            expect(result, isTrue, reason: 'Analyst should be able to view ${target.role.name}');
          });
        }
      });
    });
  });
}
