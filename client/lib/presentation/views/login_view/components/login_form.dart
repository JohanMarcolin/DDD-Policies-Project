part of '../login_view.dart';

class LoginForm extends StatefulWidget {
  LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoginEmailField(emailController: _emailController),
              LoginPasswordField(passwordController: _passwordController),
              const SizedBox(height: 20),
              LoginButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
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
        );
      },
    );
  }
}
