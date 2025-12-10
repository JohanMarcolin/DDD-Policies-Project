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
    group('viewUsers', () {
      group('User', () {
        test('should be able to view self', () async {
          final self = mockUser;
          final users = await userAdministrationService.viewUsers(initiator: self);
          expect(users, contains(self), reason: 'User should be able to view self');
        });
        for (final other in [otherMockUser, mockAdmin]) {
          test('should be able to view ${other.role.name}', () async {
            final users = await userAdministrationService.viewUsers(initiator: mockUser);
            expect(users, contains(other), reason: 'User should be able to view ${other.role.name}');
          });
        }
        test('should not be able to view analyst', () async {
          final users = await userAdministrationService.viewUsers(initiator: mockUser);
          expect(users, isNot(contains(mockAnalyst)), reason: 'User should not be able to view analyst');
        });
      });
      group('Admin', () {
        test('should be able to view self', () async {
          final self = mockAdmin;
          final users = await userAdministrationService.viewUsers(initiator: self);
          expect(users, contains(self), reason: 'Admin should be able to view self');
        });
        for (final other in [mockUser, otherMockAdmin]) {
          test('should be able to view ${other.role.name}', () async {
            final users = await userAdministrationService.viewUsers(initiator: mockAdmin);
            expect(users, contains(other), reason: 'Admin should be able to view ${other.role.name}');
          });
        }
        test('should not be able to view analyst', () async {
          final users = await userAdministrationService.viewUsers(initiator: mockAdmin);
          expect(users, isNot(contains(mockAnalyst)), reason: 'Admin should not be able to view analyst');
        });
      });
      group('Analyst', () {
        test('should be able to view self', () async {
          final self = mockAnalyst;
          final users = await userAdministrationService.viewUsers(initiator: self);
          expect(users, contains(self), reason: 'Analyst should be able to view self');
        });
        for (final other in [mockUser, mockAdmin, otherMockAnalyst]) {
          test('should be able to view ${other.role.name}', () async {
            final users = await userAdministrationService.viewUsers(initiator: mockAnalyst);
            expect(users, contains(other), reason: 'Analyst should be able to view ${other.role.name}');
          });
        }
      });
    });
  });
}
