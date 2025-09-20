import 'package:client/presentation/widgets/button.dart';
import 'package:flutter/material.dart';

class LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool loading;
  const LogoutButton({
    super.key,
    required this.onPressed,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Button(text: 'Logout', onPressed: onPressed, loading: loading);
  }
}
