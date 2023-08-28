import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mawaqit/main.dart';
import 'package:mawaqit/src/helpers/Api.dart';
import 'package:mawaqit/src/widgets/ScreenWithAnimation.dart';

class AppUpdateScreen extends StatefulWidget {
  const AppUpdateScreen({super.key});

  @override
  State<AppUpdateScreen> createState() => _AppUpdateScreenState();
}

class _AppUpdateScreenState extends State<AppUpdateScreen> {
  double value = 0;

  checkIfThereAreAnOldDownloadedVersion() async {}

  updateProgress(double value) => setState(() => this.value = value);

  downloadApk() async {
    final url = await Api.downloadApk(onProgress: updateProgress);

    final oldFile = File(url);

    logger.d("oldFile: $url");

    // final installer = FlutterAppInstaller();
    // if (await oldFile.exists())
    //   await installer.installApk(filePath: url.replaceAll('/data', ''));
    // else
    //   logger.d("File not found $url");
  }

  @override
  void initState() {
    downloadApk();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: ScreenWithAnimationWidget(
        animation: 'welcome',
        child: Align(
          alignment: Alignment(1, -.3),
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                value == 100 ? "Apk install" : "App Update",
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              Text(
                value == 100 ? 'Download completed... installing apk' : 'Downloading new apk version... please wait...',
                style: theme.textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 50),
              if (value != 100) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Downloading..."),
                    Text("${value.toStringAsFixed(0)}%"),
                  ],
                ),
                LinearProgressIndicator(
                  value: value == 0 ? null : value / 100,
                ),
              ] else ...[
                Center(child: CircularProgressIndicator()),
                SizedBox(height: 10),
                Text("Installing...", textAlign: TextAlign.center),
              ],
              SizedBox(height: 50),
              FractionallySizedBox(
                widthFactor: .7,
                child: OutlinedButton(onPressed: () {}, child: Text("Cancel")),
              )
            ],
          ),
        ),
      ),
    );
  }
}
