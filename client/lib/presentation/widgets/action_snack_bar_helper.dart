import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

typedef CustomSnackBar = Flushbar;

class ActionSnackBarHelper {
  static CustomSnackBar? _currentSnackBar;

  static void show({required String message, required BuildContext context}) {
    _currentSnackBar?.dismiss();
    _currentSnackBar =
        CustomSnackBar(
            message: message,
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.black87,
            margin: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(8),
            flushbarPosition: FlushbarPosition.TOP,
          )
          ..show(context).then((_) {
            _currentSnackBar = null;
          });
  }
}
