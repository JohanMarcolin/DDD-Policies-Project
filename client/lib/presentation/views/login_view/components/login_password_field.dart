part of '../login_view.dart';
class LoginPasswordField extends StatelessWidget {
  const LoginPasswordField({super.key, required this.passwordController});

  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: passwordController,
      decoration: const InputDecoration(labelText: 'Password'),
      obscureText: true,
    );
  }
}
