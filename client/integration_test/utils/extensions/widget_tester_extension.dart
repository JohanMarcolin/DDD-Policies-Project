import 'package:client/infrastructure/apis/auth_api.dart';
import 'package:client/infrastructure/auth_bloc/auth_bloc.dart';
import 'package:client/presentation/views/user_administration_view/blocs/users_view_bloc/user_administration_view_bloc.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:domain/repositories/user_repository.dart';
import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../test/bloc/utils/mock_users.dart' show mockUser;

class MockAuthApi extends Mock implements AuthApi {}

class MockUserRepository extends Mock implements UserRepository {}

extension WidgetTesterExtension on WidgetTester {
  static late AuthBloc _authBlocWithStubs;
  static late UserAdministrationViewBloc _blocWithStubs;

  AuthBloc get authBlocWithStubs => _authBlocWithStubs;
  UserAdministrationViewBloc get blocWithStubs => _blocWithStubs;

  Future<void> renderWidgetWithBlocStubs({
    required Widget testWidget,
    User? currentUser,
    MockAuthApi? mockAuthApi,
    MockUserRepository? mockUserRepository,
  }) async {
    final user = currentUser ?? mockUser;
    final repository = mockUserRepository ?? MockUserRepository();
    final authApi = mockAuthApi ?? MockAuthApi();

    _authBlocWithStubs = AuthBloc(authApi: authApi);

    final stubbedUserAdministrationService =
        _getStubbedUserAdministrationService(repository);

    _blocWithStubs = _getStubbedUserAdministrationViewBloc(
      user,
      stubbedUserAdministrationService,
    );

    await pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: _authBlocWithStubs),
          BlocProvider<UserAdministrationViewBloc>.value(value: _blocWithStubs),
        ],
        child: MaterialApp(home: Material(child: testWidget)),
      ),
    );
  }

  UserAdministrationViewBloc _getStubbedUserAdministrationViewBloc(
    User currentUser,
    UserAdministrationService stubbedUserAdministrationService,
  ) {
    return UserAdministrationViewBloc(
      currentUser: currentUser,
      userAdministrationService: stubbedUserAdministrationService,
    );
  }

  UserAdministrationService _getStubbedUserAdministrationService(
    MockUserRepository mockUserRepository,
  ) {
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
}
