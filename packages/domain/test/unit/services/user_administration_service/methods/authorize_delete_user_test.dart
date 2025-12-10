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
    group('authorizeDeleteUser', () {
      group('User', () {
        test('should authorize deleting self', () {
          final self = user;
          final result = userAdministrationService.authorizeDeleteUser(
            initiator: self,
            target: self,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isTrue, reason: 'Users should be able to delete themselves');
        });
        for (final other in [otherUser, admin, analyst]) {
          test('should not authorize deleting ${other.role.name}', () {
            final result = userAdministrationService.authorizeDeleteUser(
              initiator: user,
              target: other,
              onAuthorized: () => true,
              onUnauthorized: (reason) => false,
            );
            expect(result, isFalse, reason: 'Users should not be able to delete ${other.role.name}');
          });
        }
      });
      group('Admin', () {
        test('should authorize deleting self', () {
          final self = admin;
          final result = userAdministrationService.authorizeDeleteUser(
            initiator: self,
            target: self,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isTrue);
        });
        for (final other in [user, otherAdmin]) {
          test('should authorize deleting ${other.role.name}', () {
            final result = userAdministrationService.authorizeDeleteUser(
              initiator: admin,
              target: other,
              onAuthorized: () => true,
              onUnauthorized: (reason) => false,
            );
            expect(result, isTrue, reason: 'Admins should be able to delete ${other.role.name}');
          });
        }
        test('should not authorize deleting analysts', () {
          final result = userAdministrationService.authorizeDeleteUser(
            initiator: admin,
            target: analyst,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isFalse, reason: 'Admins should not be able to delete Analysts');
        });
      });
      group('Analyst', () {
        test('should not authorize deleting self', () {
          final self = analyst;
          final result = userAdministrationService.authorizeDeleteUser(
            initiator: self,
            target: self,
            onAuthorized: () => true,
            onUnauthorized: (reason) => false,
          );
          expect(result, isFalse);
        });
        for (final other in [user, admin, otherAnalyst]) {
          test('should authorize deleting ${other.role.name}', () {
            final result = userAdministrationService.authorizeDeleteUser(
              initiator: analyst,
              target: other,
              onAuthorized: () => true,
              onUnauthorized: (reason) => false,
            );
            expect(result, isTrue, reason: 'Analysts should be able to delete ${other.role.name}');
          });
        }
      });
    });
  });
}
