import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppUpdateDialog extends StatelessWidget {
  const AppUpdateDialog({
    super.key,
    required this.onLater,
    required this.onNever,
    required this.onUpdate,
  });

  final VoidCallback? onLater;
  final VoidCallback? onNever;
  final VoidCallback? onUpdate;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Update Available'),
      content: Text(
        'A new version of the app is available. Please update to the latest version.',
      ),

      actions: [
        TextButton(
          onPressed: onLater,
          child: Text('Later'),
        ),
        TextButton(
          onPressed: onNever,
          child: Text('Never'),
        ),
        TextButton(
          onPressed: onUpdate,
          child: Text('Update'),
        ),
      ],
    );
  }
}
