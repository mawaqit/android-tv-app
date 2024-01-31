import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionWidget extends StatelessWidget {
  const VersionWidget({Key? key, this.style, this.textAlign}) : super(key: key);

  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) => Text(
        "v${snapshot.data?.version.replaceAll('-tv', '')}-${snapshot.data?.buildNumber}",
        style: style,
        textAlign: textAlign,
      ),
    );
  }
}
