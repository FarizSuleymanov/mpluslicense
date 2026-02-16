import 'package:flutter/material.dart';

class ReturnMessages {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
      BuildContext context, String text, int status) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          backgroundColor: status == 0 ? Colors.red : Colors.green,
          content: Center(
              child: Text(
            text,
            style: const TextStyle(fontSize: 20),
          ))),
    );
  }
}
