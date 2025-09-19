import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String label;
  final void Function(String) onConfirm;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.label,
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
        obscureText: label.toLowerCase().contains('password'),
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
    required void Function(String) onConfirm,
  }) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) =>
          ConfirmDialog(title: title, label: label, onConfirm: onConfirm),
    );
    if (result != null && result.isNotEmpty) {
      onConfirm(result);
    }
  }
}
