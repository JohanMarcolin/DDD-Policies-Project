import 'package:client/presentation/widgets/base_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:domain/value_objects/email.dart';
import 'package:domain/value_objects/password.dart';
import 'package:client/infrastructure/auth_bloc/auth_bloc.dart';

import 'components/login_button.dart';

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
        if (state is AuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Auth failed')));
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
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
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
