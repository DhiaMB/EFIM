import 'package:flutter/material.dart';

Future<void> showErrorDialog(BuildContext context, String text) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Sign in Failed'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Error: $text'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Approve'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}