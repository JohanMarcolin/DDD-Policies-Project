import 'package:client/infrastructure/apis/auth_api.dart';
import 'package:client/infrastructure/apis/user_api.dart';
import 'package:client/infrastructure/services/auth_token_service.dart';
import 'package:client/presentation/views/login_view/login_view.dart';
import 'package:domain/entities/user.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easy_dialogs/flutter_easy_dialogs.dart';
import 'infrastructure/auth_bloc/auth_bloc.dart';
import 'infrastructure/repositories/http_user_repository.dart';
import 'presentation/views/user_administration_view/blocs/users_view_bloc/user_administration_view_bloc.dart';
import 'presentation/views/user_administration_view/user_administration_view.dart';

void main() {
  final authBloc = AuthBloc(authApi: AuthApi(authTokenService: AuthTokenService()));

  runApp(
    MultiBlocProvider(
      providers: [BlocProvider<AuthBloc>(create: (_) => authBloc..add(AuthRefreshAccessTokenRequested()))],
      child: const UserAdministrationApp(),
    ),
  );
}

class UserAdministrationApp extends StatelessWidget {
  const UserAdministrationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Administration App',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      builder: FlutterEasyDialogs.builder(),
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            final userAdministrationViewBloc = _setupUserAdministrationViewBloc(state.currentUser);
            return BlocProvider(
              create: (_) => userAdministrationViewBloc..add(FetchUsersRequested()),
              child: const UserAdministrationView(),
            );
          }

          return const LoginView();
        },
      ),
    );
  }

  UserAdministrationViewBloc _setupUserAdministrationViewBloc(User currentUser) {
    return UserAdministrationViewBloc(
      currentUser: currentUser,
      userAdministrationService: UserAdministrationService(
        userRepository: HttpUserRepository(
          userApi: UserApi(
            authApi: AuthApi(authTokenService: AuthTokenService()),
            authTokenService: AuthTokenService(),
          ),
        ),
        viewUserPolicy: ViewUserPolicy(),
        updateUserEmailPolicy: UpdateUserEmailPolicy(),
        updateUserPasswordPolicy: UpdateUserPasswordPolicy(),
        deleteUserPolicy: DeleteUserPolicy(),
        emailValidationPolicy: EmailValidationPolicy(),
        passwordValidationPolicy: PasswordValidationPolicy(),
      ),
    );
  }
}
