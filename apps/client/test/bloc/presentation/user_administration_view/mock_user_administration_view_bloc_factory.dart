import 'package:client/presentation/views/user_administration_view/blocs/users_view_bloc/user_administration_view_bloc.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:domain/repositories/user_repository.dart' as domain;
import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements domain.UserRepository {}

class MockUserAdministrationViewBlocFactory {
  MockUserAdministrationViewBlocFactory._(this.mockServiceRepository, this.mockBloc);
  factory MockUserAdministrationViewBlocFactory({required User currentUser}) {
    final mockServiceRepository = MockUserRepository();

    final mockService = UserAdministrationService(
      userRepository: mockServiceRepository,
      viewUserPolicy: ViewUserPolicy(),
      updateUserEmailPolicy: UpdateUserEmailPolicy(),
      updateUserPasswordPolicy: UpdateUserPasswordPolicy(),
      deleteUserPolicy: DeleteUserPolicy(),
      emailValidationPolicy: EmailValidationPolicy(),
      passwordValidationPolicy: PasswordValidationPolicy(),
    );

    final mockBloc = UserAdministrationViewBloc(currentUser: currentUser, userAdministrationService: mockService);
    return MockUserAdministrationViewBlocFactory._(mockServiceRepository, mockBloc);
  }

  final MockUserRepository mockServiceRepository;
  final UserAdministrationViewBloc mockBloc;

  void dispose() => mockBloc.close();
}
