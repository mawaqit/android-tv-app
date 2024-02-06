import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../services/user_preferences_manager.dart';

class VersionWidget extends StatefulWidget {
  const VersionWidget({Key? key, this.style, this.textAlign}) : super(key: key);

  final TextStyle? style;
  final TextAlign? textAlign;

  String _formatVersion(PackageInfo? packageInfo) {
    final version = packageInfo?.version.replaceAll('-tv', '') ?? '';
    final buildNumber = packageInfo?.buildNumber ?? '';
    return "v$version-$buildNumber";
  }

  @override
  _VersionWidgetState createState() => _VersionWidgetState();
}

class _VersionWidgetState extends State<VersionWidget> {
  int tapCount = 0;

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) => Text(
        _formatVersion(snapshot.data),
        style: style,
        textAlign: textAlign,
      ),
    );
  }
}
