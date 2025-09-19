import 'package:client/presentation/users_view/components/button.dart';
import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool loading;
  const LoginButton({
    super.key,
    required this.onPressed,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Button(text: 'Login', onPressed: onPressed, loading: loading);
  }
}
