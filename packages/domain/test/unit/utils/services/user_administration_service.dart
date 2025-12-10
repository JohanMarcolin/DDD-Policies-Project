import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_authorization_policies/user_administration/user_administration_policy.dart';
import 'package:domain/policies/value_validation_policies/user_credentials/user_credential_policy.dart';
import 'package:domain/services/user_administration/user_administration_service.dart';
import '../repositories/dummy_user_repository.dart';

UserAdministrationService createTestUserAdministrationService([List<User> mockUsers = const []]) {
  return UserAdministrationService(
    userRepository: DummyUserRepository(mockUsers),
    viewUserPolicy: ViewUserPolicy(),
    updateUserEmailPolicy: UpdateUserEmailPolicy(),
    updateUserPasswordPolicy: UpdateUserPasswordPolicy(),
    deleteUserPolicy: DeleteUserPolicy(),
    userEmailValidationPolicy: UserEmailValidationPolicy(),
    userPasswordValidationPolicy: UserPasswordValidationPolicy(),
  );
}
