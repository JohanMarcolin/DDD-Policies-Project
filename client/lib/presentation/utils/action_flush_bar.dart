import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

Flushbar<dynamic>? _currentFlushbar;

void showAppFlushbar({required String message, required BuildContext context}) {
  // Dismiss any currently visible flushbar
  _currentFlushbar?.dismiss();

  // Create and show the new flushbar
  _currentFlushbar =
      Flushbar(
          message: message,
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.black87,
          margin: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(8),
          flushbarPosition: FlushbarPosition.TOP,
          // Add any other default settings here
        )
        ..show(context).then((_) {
          // Clear the reference when dismissed
          _currentFlushbar = null;
        });
}
