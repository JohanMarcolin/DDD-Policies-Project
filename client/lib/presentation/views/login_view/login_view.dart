import 'package:client/presentation/widgets/action_snack_bar_helper.dart';
import 'package:client/presentation/widgets/base_app_bar.dart';
import 'package:error_codes/error_codes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/password.dart';
import 'package:client/infrastructure/auth_bloc/auth_bloc.dart';

import 'components/login_button.dart';
import 'components/login_email_field.dart';
import 'components/login_password_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        switch (state) {
          case Authenticated():
            ActionSnackBarHelper.show(
              message: 'Logged in as ${state.currentUser.email.value}',
            );
          case Unauthenticated():
            final message = switch (state.errorCode) {
              LoginMissingEmail() => 'Please enter your email.',
              LoginMissingPassword() => 'Please enter your password.',
              LoginUserNotFound() => 'Email not found.',
              LoginInvalidPassword() => 'Invalid password.',
              RefreshMissingRefreshToken() =>
                'Missing refresh token. Please log in again.',
              RefreshUserNotFound() =>
                'User ID not found. Please log in again.',
              _ => null,
            };
            if (message != null) ActionSnackBarHelper.show(message: message);
          case AuthFailure():
            ActionSnackBarHelper.show(
              message: 'Authentication failed. Please try again.',
            );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: const BaseAppBar(title: 'Login'),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoginEmailField(emailController: _emailController),
                LoginPasswordField(passwordController: _passwordController),
                const SizedBox(height: 20),
                LoginButton(
                  onPressed: () {
                    BlocProvider.of<AuthBloc>(context).add(
                      AuthLoginRequested(
                        email: Email(_emailController.text),
                        password: Password(_passwordController.text),
                      ),
                    );
                  },
                  loading: state is AuthLoading,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
