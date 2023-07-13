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
