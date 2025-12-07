import 'package:domain/policies/action_authorization_policies/user_administration/user_administration_policy.dart';
import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:test_utils/mocks/mock_user_repository.dart';

UserAdministrationService createStubbedUserAdministrationService([MockUserRepository? mockUserRepository]) {
  mockUserRepository ??= MockUserRepository();

  return UserAdministrationService(
    userRepository: mockUserRepository,
    viewUserPolicy: ViewUserPolicy(),
    updateUserEmailPolicy: UpdateUserEmailPolicy(),
    updateUserPasswordPolicy: UpdateUserPasswordPolicy(),
    deleteUserPolicy: DeleteUserPolicy(),
    emailValidationPolicy: EmailValidationPolicy(),
    passwordValidationPolicy: PasswordValidationPolicy(),
  );
}
