import 'package:flutter/material.dart';

class ActionDialogHelper {
  static Widget? currentChild;

  static Future<void> show({required BuildContext context, required Widget child}) {
    currentChild = child;
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(child: child, insetPadding: EdgeInsets.all(24), backgroundColor: Colors.transparent),
    );
  }

  static Future<void> close(BuildContext context) {
    currentChild = null;
    Navigator.of(context, rootNavigator: true).pop();
    return Future.value();
  }
}
