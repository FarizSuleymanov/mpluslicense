import 'package:flutter/material.dart';

class ShowAlertDialog {
  String? selectedCompanyIndex;

  Future<void> showYesNoDialog(BuildContext context, String header,
      String message, Future<void> Function() onPressedYes) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(header),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Bəli'),
              onPressed: () async {
                await onPressedYes();
                if (!context.mounted) return;
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Xeyr'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
