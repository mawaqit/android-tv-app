import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../services/user_preferences_manager.dart';

class VersionWidget extends StatefulWidget {
  const VersionWidget({Key? key, this.style, this.textAlign}) : super(key: key);

  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  _VersionWidgetState createState() => _VersionWidgetState();
}

class _VersionWidgetState extends State<VersionWidget> {
  int tapCount = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
onTap: () {
        setState(() {
          if (context.read<UserPreferencesManager>().developerModeEnabled) {
            // Deactivate debug menu
            context.read<UserPreferencesManager>().developerModeEnabled = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    "You have desactivated the Abogabal secret menu 😎💪 رائع! لقد قمت بإلغاء تنشيط قائمة أبو جبل السرية"),
              ),
            );
          } else {
            tapCount++;
            if (tapCount >= 7) {
              context.read<UserPreferencesManager>().developerModeEnabled =
                  true;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "You have activated the Abogabal secret menu 😎💪 رائع! لقد قمت بتنشيط قائمة أبو جبل السرية",
                  ),
                ),
              );
              tapCount = 0; // Reset tapCount after activation
            }
          }
        });
      },

      child: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) => Text(
          "v${snapshot.data?.version.replaceAll('-tv', '')}-${snapshot.data?.buildNumber}",
          style: widget.style,
          textAlign: widget.textAlign,
        ),
      ),
    );
  }
}
