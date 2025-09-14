import 'package:test/test.dart';
import '../../../../domain/services/user_administration/user_administration_service.dart';
import '../../../../domain/value_objects/email.dart';
import '../../../../domain/value_objects/password.dart';
import '../../../utils/factories/test_user_factory.dart';
import '../../../utils/policies/action_policies/dummy_action_policy.dart';
import '../../../utils/policies/validation_policies/dummy_validation_policy.dart';
import '../../../utils/repositories/dummy_user_repository.dart';

void main() {
  final user1 = TestUserFactory.user1;
  final user2 = TestUserFactory.user2;

  late UserAdministrationService userAdministrationService;

  setUpAll(() {
    userAdministrationService = UserAdministrationService(
      userRepository: DummyUserRepository([user1, user2]),
      viewUserPolicy: DummyAlwaysGrantedActionPolicy(),
      updateUserEmailPolicy: DummyAlwaysGrantedActionPolicy(),
      updateUserPasswordPolicy: DummyAlwaysGrantedActionPolicy(),
      deleteUserPolicy: DummyAlwaysGrantedActionPolicy(),
      emailValidationPolicy: DummyAlwaysValidValidationPolicy<Email>(),
      passwordValidationPolicy: DummyAlwaysValidValidationPolicy<Password>(),
    );
  });
  group('UserAdministrationService', () {
    test('getUsers returns all users permitted', () {
      final users = userAdministrationService.getUsers(initiator: user1);
      expect(users, containsAll([user1, user2]));
    });
    test('get returns user by id', () {
      final user =
          userAdministrationService.get(initiator: user1, id: user2.id);
      expect(user, equals(user2));
    });
    test('getByEmail returns user by email', () {
      final user = userAdministrationService.getByEmail(
          initiator: user1, email: user2.email);
      expect(user, equals(user2));
    });
    test('deleteUser removes user', () {
      userAdministrationService.deleteUser(initiator: user1, target: user2);
      final users = userAdministrationService.getUsers(initiator: user1);
      expect(users, isNot(contains(user2)));
    });
    test('updateUserEmail updates email', () {
      final newEmail = Email('new@email.com');
      userAdministrationService.updateUserEmail(
          initiator: user1, target: user1, newEmail: newEmail);
      final users = userAdministrationService.getUsers(initiator: user1);
      final updatedUser = users.firstWhere((u) => u.id == user1.id);
      expect(updatedUser.email, equals(newEmail));
    });
  });
}
