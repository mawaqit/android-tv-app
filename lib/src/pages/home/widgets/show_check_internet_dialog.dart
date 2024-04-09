import 'package:flutter/material.dart';

import '../../../../i18n/l10n.dart';

void showCheckInternetDialog({
  required BuildContext context,
  required VoidCallback onRetry,
  required String title,
  required String content,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      final String retry = S.of(context).retry;
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(content),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(retry),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
    },
  );
}
