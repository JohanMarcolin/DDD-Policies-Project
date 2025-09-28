import 'package:flutter/material.dart';

class ConfirmInputDialog extends StatelessWidget {
  final String title;
  final String label;
  final bool isTextObscured;
  final Future<void> Function() onCancel;
  final void Function(String) onConfirm;

  const ConfirmInputDialog({
    super.key,
    required this.title,
    required this.label,
    this.isTextObscured = false,
    required this.onCancel,
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
        TextButton(child: const Text('Cancel'), onPressed: () => onCancel()),
        TextButton(
          child: const Text('Confirm'),
          onPressed: () => onConfirm(controller.text),
        ),
      ],
    );
  }
}
