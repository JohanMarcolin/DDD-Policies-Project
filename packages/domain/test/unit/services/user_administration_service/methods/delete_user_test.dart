import 'package:domain/policies/action_authorization_policies/user_administration/user_administration_policy.dart';
import 'package:domain/policies/policy_violation_exception.dart';
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
    group('deleteUser', () {
      group('User', () {
        test('should be able to delete self', () async {
          final self = user;
          await userAdministrationService.deleteUser(initiator: self, target: self);
          final users = await userAdministrationService.viewUsers(initiator: self);
          expect(users, isNot(contains(self)), reason: 'User should be able to delete self');
        });
        for (final other in [otherUser, admin, analyst]) {
          test('should not be able to delete ${other.role.name}', () async {
            expect(
                () async => await userAdministrationService.deleteUser(initiator: user, target: other),
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
          final self = admin;
          await userAdministrationService.deleteUser(initiator: self, target: self);
          final users = await userAdministrationService.viewUsers(initiator: self);
          expect(users, isNot(contains(self)), reason: 'Admin should be able to delete self');
        });
        for (final other in [user, otherAdmin]) {
          test('should be able to delete ${other.role.name}', () async {
            await userAdministrationService.deleteUser(initiator: admin, target: other);
            final users = await userAdministrationService.viewUsers(initiator: admin);
            expect(users, isNot(contains(other)), reason: 'Admin should be able to delete ${other.role.name}');
          });
        }
        test('should not be able to delete analyst', () async {
          expect(
              () async => await userAdministrationService.deleteUser(initiator: admin, target: analyst),
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
              () async => await userAdministrationService.deleteUser(initiator: analyst, target: analyst),
              throwsA(
                predicate(
                  (e) => e is PolicyViolationException<DeleteUserUnauthorizedReason> && e.reason == CannotDeleteSelf(),
                ),
              ),
              reason: 'Analyst should not be able to delete self');
        });
        for (final other in [user, admin, otherAnalyst]) {
          test('should be able to delete ${other.role.name}', () async {
            await userAdministrationService.deleteUser(initiator: analyst, target: other);
            final users = await userAdministrationService.viewUsers(initiator: analyst);
            expect(users, isNot(contains(other)), reason: 'Analyst should be able to delete ${other.role.name}');
          });
        }
      });
    });
  });
}
