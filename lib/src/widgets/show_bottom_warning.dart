import 'package:flash/flash.dart';
import 'package:flash/flash_helper.dart';
import 'package:flutter/material.dart';

import '../../i18n/l10n.dart';

/// Displays a customizable warning message at the bottom of the screen.
///
/// This function creates a bottom-positioned FlashBar (a temporary alert)
Future<void> showBottomWarning({
  required BuildContext context,
  required String title,
  required String content,
  required Duration duration,
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
        indicatorColor: Colors.red,
        icon: Icon(Icons.error_outline),
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: controller.dismiss, child: Text(localization.cancel)),
          TextButton(onPressed: () => controller.dismiss(true), child: Text(localization.ok))
        ],
      );
    },
  );
}
