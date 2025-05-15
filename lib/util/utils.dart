import 'package:flutter/material.dart';

void showCenteredToast(BuildContext context, String message) {
  final scaffold = ScaffoldMessenger.of(context);
  scaffold.showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.red,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      duration: Duration(seconds: 3),
      action: SnackBarAction(label: 'OK', onPressed: scaffold.hideCurrentSnackBar),
      elevation: 0,//new change for the shadow
    ),
  );
}