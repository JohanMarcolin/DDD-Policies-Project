import 'package:client/presentation/widgets/action_snack_bar_helper.dart';
import 'package:client/presentation/widgets/button.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client/infrastructure/auth_bloc/auth_bloc.dart';
import 'package:api_error_codes/api_error_codes.dart';

part 'components/login_app_bar.dart';
part 'components/login_form.dart';
part 'components/login_email_field.dart';
part 'components/login_password_field.dart';
part 'components/login_button.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        switch (state) {
          case AuthInitial():
          case AuthLoading():
            return;
          case Authenticated():
            ActionSnackBarHelper.show(message: 'Logged in as ${state.currentUser.email.value}');
          case Unauthenticated():
            final message = switch (state.apiErrorCode) {
              LoginMissingEmail() => 'Please enter your email',
              LoginMissingPassword() => 'Please enter your password',
              LoginUserNotFound() => 'Email not found',
              LoginInvalidPassword() => 'Invalid password',
              TokenRefreshTokenMissing() => 'Missing refresh token. Please log in again',
              TokenRefreshTokenUserNotFound() => 'User ID not found. Please log in again',
              _ => null,
            };
            if (message != null) ActionSnackBarHelper.show(message: message);
          case AuthFailure():
            ActionSnackBarHelper.show(message: 'Authentication failed. Please try again');
        }
      },
      child: Scaffold(appBar: const LoginAppBar(), body: LoginForm()),
    );
  }
}
