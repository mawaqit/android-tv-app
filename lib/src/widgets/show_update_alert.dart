import 'package:flash/flash_helper.dart';
import 'package:flutter/material.dart';
import 'package:flash/flash.dart';
import '../../i18n/l10n.dart';

/// Displays a customizable warning message at the bottom of the screen.
///
/// This function creates a bottom-positioned FlashBar (a temporary alert)
Future<void> showUpdateAlert({
  required BuildContext context,
  required String title,
  required String content,
  required Duration duration,
  required VoidCallback onPressed,
  required VoidCallback onDismissPressed,
}) async {
  await context.showFlash<bool>(
    barrierDismissible: true,
    duration: duration,
    builder: (context, controller) {
      final localization = S.of(context);

      return FlashBar(
        controller: controller,
        forwardAnimationCurve: Curves.easeInCirc,
        reverseAnimationCurve: Curves.bounceIn,
        position: FlashPosition.bottom,
        icon: Icon(Icons.new_releases),
        title: Text(localization.updateAvailable),
        actions: [
          TextButton(
            onPressed: () {
              controller.dismiss();
              onDismissPressed();
            },
            child: Text(localization.cancel),
          ),
          TextButton(onPressed: onPressed, child: Text(localization.ok)),
          TextButton(
              onPressed: () {
                controller.dismiss();
                _showUpdateVersionDialog(
                  context,
                  content,
                  onPressed,
                  onDismissPressed,
                );
              },
              child: Text(localization.seeMore)),
        ],
        content: Text(title),
      );
    },
  );
}

Future<void> _showUpdateVersionDialog(
  BuildContext context,
  String content,
  VoidCallback onPressed,
  VoidCallback onDismissPressed,
) async {
  final l10n = S.of(context);
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(l10n.whatIsNew),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[Text(content)],
          ),
        ),
        actions: <Widget>[
          TextButton(
              child:  Text(l10n.update),
              onPressed: () {
                onPressed();
                Navigator.of(context).pop();
              }),
          TextButton(
              child: Text(l10n.cancel),
              onPressed: () {
                onDismissPressed();
                Navigator.of(context).pop();
              }),
        ],
      );
    },
  );
}
