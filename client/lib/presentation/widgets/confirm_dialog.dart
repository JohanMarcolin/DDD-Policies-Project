import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String label;
  final Future<void> Function() onCancel;
  final VoidCallback onConfirm;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.label,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(label),
      actions: [
        TextButton(child: const Text('Cancel'), onPressed: () => onCancel()),
        TextButton(child: const Text('Confirm'), onPressed: onConfirm),
      ],
    );
  }
}
