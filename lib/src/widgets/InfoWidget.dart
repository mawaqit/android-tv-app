import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class VersionWidget extends StatelessWidget {
  const VersionWidget({Key? key, this.style, this.textAlign}) : super(key: key);

  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) => Text(
        "v${snapshot.data?.version} (${snapshot.data?.buildNumber})",
        style: style,
        textAlign: textAlign,
      ),
    );
  }
}
