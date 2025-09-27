import 'package:flutter/material.dart';

class ActionSnackBar extends StatelessWidget {
  final String text;
  final BuildContext snackBarContext;

  const ActionSnackBar({
    super.key,
    required this.text,
    required this.snackBarContext,
  });

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(snackBarContext)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(text)));
    });
    return const SizedBox.shrink();
  }
}
