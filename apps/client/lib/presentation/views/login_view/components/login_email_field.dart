part of '../login_view.dart';

class LoginEmailField extends StatelessWidget {
  const LoginEmailField({super.key, required this.emailController});

  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: emailController,
      decoration: const InputDecoration(labelText: 'Email'),
    );
  }
}
