import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/Api.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/pages/home/widgets/mosque_background_screen.dart';
import 'package:mawaqit/src/widgets/ScreenWithAnimation.dart';

class AppUpdateScreen extends StatefulWidget {
  const AppUpdateScreen({super.key});

  @override
  State<AppUpdateScreen> createState() => _AppUpdateScreenState();
}

class _AppUpdateScreenState extends State<AppUpdateScreen> {
  double value = 0;
  StreamSubscription? _subscription;

  checkIfThereAreAnOldDownloadedVersion() async {}

  downloadApk() async {
    _subscription = Api.downloadApk().listen((event) {
      setState(() {
        value = event;
      });
    }, onDone: installDownloadedApk, onError: AppRouter.pop);
  }

  installDownloadedApk() async {}

  @override
  void initState() {
    downloadApk();
    super.initState();
  }

  @override
  void dispose() {
    _subscription?.cancel();
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
              Text("App Update", style: theme.textTheme.headlineMedium),
              Text(
                'Downloading new apk version... please wait...',
                style: theme.textTheme.labelMedium,
              ),
              SizedBox(height: 50),
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
            ],
          ),
        ),
      ),
    );
  }
}
