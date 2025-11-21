import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ActionSnackBarHelper {
  static String? lastMessage;

  static void show({required String message}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    if (Fluttertoast.isCurrentlyShowingToast) {
      lastMessage = message;
    } else {
      lastMessage = null;
    }
  }
}
