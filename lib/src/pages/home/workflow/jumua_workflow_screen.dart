import 'package:flutter/material.dart';
import 'package:mawaqit/src/enum/home_active_screen.dart';
import 'package:mawaqit/src/helpers/HiveLocalDatabase.dart';
import 'package:mawaqit/src/helpers/time_utils.dart';
import 'package:mawaqit/src/pages/home/sub_screens/AfterSalahAzkarScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/JummuaLive.dart';
import 'package:mawaqit/src/pages/home/sub_screens/JumuaHadithSubScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/normal_home.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

/// show the back screen during the jumuaa
class JumuaaWorkflowScreen extends StatefulWidget {
  const JumuaaWorkflowScreen({Key? key, this.onDone}) : super(key: key);
  final VoidCallback? onDone;

  @override
  State<JumuaaWorkflowScreen> createState() => _JumuaaWorkflowScreenState();
}

class _JumuaaWorkflowScreenState extends State<JumuaaWorkflowScreen> {
  JumuaaWorkflowScreens state = JumuaaWorkflowScreens.jumuaaTime;

  @override
  void initState() {
    calculateScreen();
    super.initState();
  }

  /// handle if you opend this screen before or during the jumuaa
  calculateScreen() {
    final mosqueManager = context.read<MosqueManager>();
    final now = mosqueManager.mosqueDate();
    final jumuaaTimeout = mosqueManager.mosqueConfig?.jumuaTimeout ?? 30;

    final jumuaaTime = mosqueManager.jumuaTime!.toTimeOfDay()!.toDate(now);
    final jumuaaEndTime = jumuaaTime.add(Duration(minutes: jumuaaTimeout));

    /// if we are before the jumuaa ends
    if (now.isBefore(jumuaaEndTime)) {
      setState(() => state = JumuaaWorkflowScreens.jumuaaTime);

      if (mosqueManager.jumuaaLiveUrl == null)
        Future.delayed(jumuaaEndTime.difference(now), onJumuaaEnd);
    } else {
      /// show the azkar
      onSalahEnd();
    }
  }

  ///
  onJumuaaEnd() {
    final mosqueManager = context.read<MosqueManager>();

    final salahTime = mosqueManager.mosqueConfig!.duaAfterPrayerShowTimes[1];
    final jumuaaSalahEnd = int.tryParse(salahTime);

    setState(() => state = JumuaaWorkflowScreens.jumuaaSalahTime);
    Future.delayed(Duration(minutes: jumuaaSalahEnd ?? 0), onSalahEnd);
  }

  onSalahEnd() {
    setState(() => state = JumuaaWorkflowScreens.jumuaaAzkar);
  }

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.watch<MosqueManager>();
    final hive = context.watch<HiveManager>();
    bool isMosqueScreen = !hive.isSecondaryScreen();

    switch (state) {
      case JumuaaWorkflowScreens.jumuaaTime:
        return isMosqueScreen
            ? JumuaHadithSubScreen()
            : mosqueManager.jumuaaLiveUrl != null
                ? JummuaLive(onDone: onJumuaaEnd)
                : JumuaHadithSubScreen();
      case JumuaaWorkflowScreens.jumuaaSalahTime:
        return mosqueManager.mosqueConfig!.jumuaBlackScreenEnabled == true
            ? Scaffold(backgroundColor: Colors.black)
            : NormalHomeSubScreen();
      case JumuaaWorkflowScreens.jumuaaAzkar:
        return AfterSalahAzkar(onDone: widget.onDone);
    }
  }
}
