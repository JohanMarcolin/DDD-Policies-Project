import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ActionSnackBarHelper {
  static void show({required String message}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
