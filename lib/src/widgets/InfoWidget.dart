import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionWidget extends StatelessWidget {
  const VersionWidget({Key? key, this.style, this.textAlign}) : super(key: key);

  final TextStyle? style;
  final TextAlign? textAlign;

  String _formatVersion(PackageInfo? packageInfo) {
    final version = packageInfo?.version.replaceAll('-tv', '') ?? '';
    final buildNumber = packageInfo?.buildNumber ?? '';
    return "v$version-$buildNumber";
  }

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
