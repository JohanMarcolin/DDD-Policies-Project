import 'package:client/infrastructure/apis/auth_api.dart';
import 'package:client/infrastructure/apis/user_api.dart';
import 'package:client/infrastructure/services/auth_token_service.dart';
import 'package:client/presentation/views/login_view/login_view.dart';
import 'package:domain/policies/action_policies/action_policy.dart';
import 'package:domain/policies/validation_policies/validation_policy.dart';
import 'package:domain/services/user_administration/user_administration_service.dart';
import 'package:error_codes/error_codes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easy_dialogs/flutter_easy_dialogs.dart';
import 'infrastructure/auth_bloc/auth_bloc.dart';
import 'infrastructure/repositories/http_user_repository.dart';
import 'presentation/views/user_administration_view/blocs/users_view_bloc/user_administration_view_bloc.dart';
import 'presentation/views/user_administration_view/user_administration_view.dart';
import 'presentation/widgets/action_snack_bar_helper.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) =>
              AuthBloc(authApi: AuthApi(authTokenService: AuthTokenService()))
                ..add(AuthRefreshRequested()),
        ),
      ],
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      builder: FlutterEasyDialogs.builder(),
      home: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            ActionSnackBarHelper.show(
              message: 'Logged in as ${state.currentUser.email.value}',
            );
          } else if (state is Unauthenticated) {
            ActionSnackBarHelper.show(
              message: (() {
                if (state.errorCode is LoginErrorCode) {
                  return switch (state.errorCode as LoginErrorCode) {
                    LoginMissingEmail() => 'Please enter your email.',
                    LoginMissingPassword() => 'Please enter your password.',
                    LoginUserNotFound() => 'Email not found.',
                    LoginInvalidPassword() => 'Invalid password.',
                  };
                } else if (state.errorCode is RefreshErrorCode) {
                  return switch (state.errorCode as RefreshErrorCode) {
                    RefreshMissingRefreshToken() =>
                      'Missing refresh token. Please log in again.',
                    RefreshUserNotFound() =>
                      'User ID not found. Please log in again.',
                  };
                } else {
                  return 'Logged out successfully';
                }
              })(),
            );
          } else if (state is AuthFailure) {
            ActionSnackBarHelper.show(
              message: (() {
                if (state.errorCode is LogoutErrorCode) {
                  return switch (state.errorCode as LogoutErrorCode) {
                    LogoutCouldNotRevokeRefreshToken() =>
                      'Could not log out. Please try again.',
                    LogoutMissingRefreshToken() =>
                      'Missing refresh token. Please log in again.',
                    LogoutMissingUser() => 'Missing user. Please log in again.',
                  };
                } else {
                  return 'Authentication failure. Please try again.';
                }
              })(),
            );
          }
        },
        builder: (context, state) {
          if (state is Authenticated) {
            return BlocProvider(
              create: (_) => UserAdministrationViewBloc(
                currentUser: state.currentUser,
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
              )..add(FetchUsersRequested()),
              child: const UserAdministrationView(),
            );
          }
          if (state is UserAdministrationViewLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return const LoginView();
        },
      ),
    );
  }
}
