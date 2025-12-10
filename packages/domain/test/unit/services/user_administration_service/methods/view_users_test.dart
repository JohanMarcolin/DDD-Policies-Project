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
    group('viewUsers', () {
      group('User', () {
        test('should be able to view self', () async {
          final self = user;
          final users = await userAdministrationService.viewUsers(initiator: self);
          expect(users, contains(self), reason: 'User should be able to view self');
        });
        for (final other in [otherUser, admin]) {
          test('should be able to view ${other.role.name}', () async {
            final users = await userAdministrationService.viewUsers(initiator: user);
            expect(users, contains(other), reason: 'User should be able to view ${other.role.name}');
          });
        }
        test('should not be able to view analyst', () async {
          final users = await userAdministrationService.viewUsers(initiator: user);
          expect(users, isNot(contains(analyst)), reason: 'User should not be able to view analyst');
        });
      });
      group('Admin', () {
        test('should be able to view self', () async {
          final self = admin;
          final users = await userAdministrationService.viewUsers(initiator: self);
          expect(users, contains(self), reason: 'Admin should be able to view self');
        });
        for (final other in [user, otherAdmin]) {
          test('should be able to view ${other.role.name}', () async {
            final users = await userAdministrationService.viewUsers(initiator: admin);
            expect(users, contains(other), reason: 'Admin should be able to view ${other.role.name}');
          });
        }
        test('should not be able to view analyst', () async {
          final users = await userAdministrationService.viewUsers(initiator: admin);
          expect(users, isNot(contains(analyst)), reason: 'Admin should not be able to view analyst');
        });
      });
      group('Analyst', () {
        test('should be able to view self', () async {
          final self = analyst;
          final users = await userAdministrationService.viewUsers(initiator: self);
          expect(users, contains(self), reason: 'Analyst should be able to view self');
        });
        for (final other in [user, admin, otherAnalyst]) {
          test('should be able to view ${other.role.name}', () async {
            final users = await userAdministrationService.viewUsers(initiator: analyst);
            expect(users, contains(other), reason: 'Analyst should be able to view ${other.role.name}');
          });
        }
      });
    });
  });
}
