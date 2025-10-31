import 'package:client/infrastructure/apis/auth_api.dart';
import 'package:client/infrastructure/auth_bloc/auth_bloc.dart';
import 'package:client/infrastructure/services/auth_token_service.dart';
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

class MockUserRepository extends Mock implements UserRepository {}

extension WidgetTesterExtension on WidgetTester {
  static late UserAdministrationViewBloc stubbedBloc;

  Future<void> withUserAdministrationStubs({
    required Widget testWidget,
    required User interactingUser,
    required MockUserRepository mockUserRepository,
  }) async {
    stubbedBloc = UserAdministrationViewBloc(
      currentUser: interactingUser,
      userAdministrationService: UserAdministrationService(
        userRepository: mockUserRepository,
        viewUserPolicy: ViewUserPolicy(),
        updateUserEmailPolicy: UpdateUserEmailPolicy(),
        updateUserPasswordPolicy: UpdateUserPasswordPolicy(),
        deleteUserPolicy: DeleteUserPolicy(),
        emailValidationPolicy: EmailValidationPolicy(),
        passwordValidationPolicy: PasswordValidationPolicy(),
      ),
    );

    await pumpWidget(
      BlocProvider<UserAdministrationViewBloc>.value(
        value: stubbedBloc,
        child: MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AuthBloc>.value(
                value: AuthBloc(
                  authApi: AuthApi(authTokenService: AuthTokenService()),
                ),
              ),
              BlocProvider<UserAdministrationViewBloc>.value(
                value: stubbedBloc,
              ),
            ],
            child: Material(child: testWidget),
          ),
        ),
      ),
    );
  }
}
