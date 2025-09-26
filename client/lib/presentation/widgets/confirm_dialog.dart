import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String label;
  final bool isTextObscured;
  final void Function(String) onConfirm;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.label,
    required this.isTextObscured,
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
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, controller.text);
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String label,
    bool isTextObscured = false,
    required void Function(String) onConfirm,
  }) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        label: label,
        isTextObscured: isTextObscured,
        onConfirm: onConfirm,
      ),
    );
    if (result != null && result.isNotEmpty) {
      onConfirm(result);
    }
  }
}
