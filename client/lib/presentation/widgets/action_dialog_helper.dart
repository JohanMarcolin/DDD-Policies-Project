import 'package:flutter/material.dart';
import 'package:flutter_easy_dialogs/flutter_easy_dialogs.dart';

class ActionDialogHelper {
  static const _dialogId = 'action_dialog';

  static Future<void> show({required Widget child}) {
    return FlutterEasyDialogs.show(
      EasyDialog.fullScreen(
        id: _dialogId,
        autoHideDuration: null,
        content: child,
        decoration: EasyDialogDecoration.combine([
          const EasyDialogAnimation.expansion(),
          const EasyDialogAnimation.fade(),
          EasyDialogAnimation.blurBackground(
            backgroundColor: Colors.black.withValues(alpha: 0.5),
            amount: 0,
          ),
        ]),
      ),
    );
  }

  static Future<void> hide() {
    return FlutterEasyDialogs.hide(id: _dialogId);
  }
}
