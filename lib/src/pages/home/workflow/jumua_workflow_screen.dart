import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/src/helpers/time_utils.dart';
import 'package:mawaqit/src/pages/home/sub_screens/AfterSalahAzkarScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/JummuaLive.dart';
import 'package:mawaqit/src/pages/home/sub_screens/normal_home.dart';
import 'package:mawaqit/src/pages/home/widgets/workflows/WorkFlowWidget.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

/// show the back screen during the jumuaa
class JumuaaWorkflowScreen extends StatelessWidget {
  const JumuaaWorkflowScreen({Key? key, this.onDone}) : super(key: key);
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.read<MosqueManager>();
    final now = mosqueManager.mosqueDate();

    final jumuaaTimeout = mosqueManager.mosqueConfig?.jumuaTimeout ?? 30;
    final salahTime = int.tryParse(mosqueManager.mosqueConfig!.duaAfterPrayerShowTimes[1]) ?? 0;

    final jumuaaTime = mosqueManager.jumuaTime!.toTimeOfDay()!.toDate(now);
    final jumuaaEndTime = jumuaaTime.add(Duration(minutes: jumuaaTimeout));

    return ContinuesWorkFlowWidget(
      debug: true,
      workFlowItems: [
        /// 5m before the jumuaa start time
        WorkFlowItem(
          builder: (context, next) => NormalHomeSubScreen(),
          duration: jumuaaTime.difference(now),
          skip: now.isAfter(jumuaaTime),
        ),

        WorkFlowItem(
          builder: (context, next) => JummuaLive(onDone: next),
          skip: now.isAfter(jumuaaEndTime),

          /// handle if user open screen during the jumuaa
          duration: now.isBefore(jumuaaTime) ? Duration(minutes: jumuaaTimeout) : jumuaaEndTime.difference(now),
        ),

        // salah time after jumuaa
        WorkFlowItem(
          builder: (context, next) => NormalHomeSubScreen(),
          duration: salahTime.minutes,
          skip: now.isAfter(jumuaaEndTime.add(salahTime.minutes)),
        ),

        // azkar after salah
        WorkFlowItem(
          builder: (context, next) => AfterSalahAzkar(onDone: onDone),
          debugDuration: 2.minutes,
          skip: now.isAfter(jumuaaEndTime.add((salahTime + 2).minutes)),
        ),
      ],
    );
  }
}

// class _JumuaaWorkflowScreenState extends State<JumuaaWorkflowScreen> {
//   JumuaaWorkflowScreens state = JumuaaWorkflowScreens.normal;
//
//   @override
//   void initState() {
//     calculateScreen();
//     super.initState();
//   }
//
//   /// handle if you opened this screen before or during the jumuaa
//   calculateScreen() {
//     final mosqueManager = context.read<MosqueManager>();
//     final now = mosqueManager.mosqueDate();
//
//     final jumuaaTimeout = mosqueManager.mosqueConfig?.jumuaTimeout ?? 30;
//
//     final jumuaaTime = mosqueManager.jumuaTime!.toTimeOfDay()!.toDate(now);
//     final jumuaaEndTime = jumuaaTime.add(Duration(minutes: jumuaaTimeout));
//
//     // we are in the 5 min time before the Jumuaa
//     if (now.isBefore(jumuaaTime)) {
//       Future.delayed(jumuaaTime.difference(now), onJumuaaStart);
//
//       Future.delayed(jumuaaEndTime.difference(now), onJumuaaEnd);
//     } else if (now.isBefore(jumuaaEndTime)) {
//       /// if we are before the jumuaa ends
//       setState(() => state = JumuaaWorkflowScreens.jumuaaTime);
//
//       if (mosqueManager.mosque?.streamUrl == null) Future.delayed(jumuaaEndTime.difference(now), onJumuaaEnd);
//     } else {
//       /// show the azkar
//       onSalahEnd();
//     }
//   }
//
//   onJumuaaStart() {
//     setState(() => state = JumuaaWorkflowScreens.jumuaaTime);
//   }
//
//   ///
//   onJumuaaEnd() {
//     final mosqueManager = context.read<MosqueManager>();
//
//     final salahTime = mosqueManager.mosqueConfig!.duaAfterPrayerShowTimes[1];
//     final jumuaaSalahEnd = int.tryParse(salahTime);
//
//     setState(() => state = JumuaaWorkflowScreens.jumuaaSalahTime);
//     Future.delayed(Duration(minutes: jumuaaSalahEnd ?? 0), onSalahEnd);
//   }
//
//   onSalahEnd() {
//     setState(() => state = JumuaaWorkflowScreens.jumuaaAzkar);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final mosqueManager = context.watch<MosqueManager>();
//     final userPrefs = context.watch<UserPreferencesManager>();
//     final config = mosqueManager.mosqueConfig!;
//
//     bool isMosqueScreen = !userPrefs.isSecondaryScreen;
//
//     switch (state) {
//       case JumuaaWorkflowScreens.normal:
//         return NormalHomeSubScreen();
//       case JumuaaWorkflowScreens.jumuaaTime:
//         if (mosqueManager.mosque?.streamUrl != null && !isMosqueScreen) return JummuaLive(onDone: onJumuaaEnd);
//
//         if (config.jumuaBlackScreenEnabled == true) return Material(color: Colors.black);
//
//         if (config.jumuaDhikrReminderEnabled == true) return JumuaHadithSubScreen();
//
//         return NormalHomeSubScreen();
//       case JumuaaWorkflowScreens.jumuaaSalahTime:
//         return NormalHomeSubScreen();
//       case JumuaaWorkflowScreens.jumuaaAzkar:
//         return AfterSalahAzkar(onDone: widget.onDone);
//     }
//   }
// }
