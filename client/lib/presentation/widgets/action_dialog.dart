import 'package:flutter/material.dart';
import 'package:flutter_easy_dialogs/flutter_easy_dialogs.dart';

class ActionDialogHelper {
  static const _dialogId = 'action_dialog';

  static Future<void> show({required Widget child}) {
    return FlutterEasyDialogs.show(
      EasyDialog.positioned(
        id: _dialogId,
        autoHideDuration: null,
        content: child,
        decoration: const EasyDialogDecoration.combine([
          EasyDialogDismiss.animatedTap(),
        ]),
      ),
    );
  }

  static Future<void> hide() {
    return FlutterEasyDialogs.hide(id: _dialogId);
  }
}
