import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:domain/value_objects/email.dart';
import 'package:test/test.dart';
import '../../repositories/dummy_user_repository.dart';

import '../../utils/users.dart';

void main() {
  final user1 = user;
  final user2 = otherUser;

  late UserAdministrationService userAdministrationService;

  setUpAll(() {
    userAdministrationService = UserAdministrationService(
      userRepository: DummyUserRepository([user1, user2]),
      viewUserPolicy: ViewUserPolicy(),
      updateUserEmailPolicy: UpdateUserEmailPolicy(),
      updateUserPasswordPolicy: UpdateUserPasswordPolicy(),
      deleteUserPolicy: DeleteUserPolicy(),
      emailValidationPolicy: EmailValidationPolicy(),
      passwordValidationPolicy: PasswordValidationPolicy(),
    );
  });
  group('UserAdministrationService', () {
    test('viewUsers returns all users permitted', () async {
      final users = await userAdministrationService.viewUsers(initiator: user1);
      expect(users, containsAll([user1, user2]));
    });
    test('viewUser returns user by id', () async {
      final user = await userAdministrationService.viewUser(initiator: user1, userId: user2.userId);
      expect(user, equals(user2));
    });
    test('deleteUser removes user', () async {
      await userAdministrationService.deleteUser(initiator: admin, target: user2);
      final users = await userAdministrationService.viewUsers(initiator: admin);
      expect(users, isNot(contains(user2)));
    });
    test('updateUserEmail updates email', () async {
      final newEmail = Email('new@email.com');
      userAdministrationService.updateUserEmail(initiator: user1, target: user1, newEmail: newEmail);
      final users = await userAdministrationService.viewUsers(initiator: user1);
      final updatedUser = users.firstWhere((u) => u.userId == user1.userId);
      expect(updatedUser.email, equals(newEmail));
    });
  });
}
