import 'package:flutter/material.dart';
import 'package:flutter_easy_dialogs/flutter_easy_dialogs.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String label;
  final bool isTextObscured;
  final void Function(String) onConfirm;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.label,
    this.isTextObscured = false,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        obscureText: isTextObscured,
      ),
      actions: [
        TextButton(
          onPressed: () =>
              FlutterEasyDialogs.hide(id: EasyDialogPosition.center),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => onConfirm(controller.text),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
