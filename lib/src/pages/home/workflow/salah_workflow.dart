import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/src/pages/home/sub_screens/AfterAdhanHadithSubScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/AfterSalahAzkarScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/DuaaBetweenAdhanAndIqama.dart';
import 'package:mawaqit/src/pages/home/sub_screens/IqamaSubScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/IqamaaCountDownSubScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/normal_home.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

import '../sub_screens/AdhanSubScreen.dart';
import '../widgets/WorkFlowWidget.dart';

/// handling the logic form 5min before adhan -> the last of after salah azkar
class SalahWorkflowScreen extends StatefulWidget {
  const SalahWorkflowScreen({
    Key? key,
    required this.onDone,
  }) : super(key: key);

  /// when the workflow is finished
  final void Function() onDone;

  @override
  State<SalahWorkflowScreen> createState() => _SalahWorkflowScreenState();
}

class _SalahWorkflowScreenState extends State<SalahWorkflowScreen> {
  calculateCurrentSalah(MosqueManager mosqueManger) {
    if (mosqueManger.nextSalahAfter() < Duration(minutes: 5))
      return mosqueManger.nextSalahIndex();

    return mosqueManger.salahIndex;
  }

  @override
  Widget build(BuildContext context) {
    final mosqueManger = context.watch<MosqueManager>();
    final mosqueConfig = mosqueManger.mosqueConfig!;

    final currentSalah = calculateCurrentSalah(mosqueManger);
    final now = mosqueManger.mosqueDate();
    final currentSalahTime = mosqueManger.actualTimes()[currentSalah];
    final currentIqamaTime = mosqueManger.actualIqamaTimes()[currentSalah];

    final adhanEndTime = currentSalahTime.add(mosqueManger.getAdhanDuration());
    final adhanDuaaEndTime = adhanEndTime.add(Duration(seconds: 35));
    final iqamaEndTime = currentIqamaTime.add(Duration(minutes: 1));
    final salahTime =
        mosqueManger.mosqueConfig!.duaAfterPrayerShowTimes[currentSalah];
    final salahEndTime = iqamaEndTime.add(
      Duration(minutes: int.tryParse(salahTime) ?? 0),
    );

    return ContinuesWorkFlowWidget(
      onDone: widget.onDone,
      workFlowItems: [
        WorkFlowItem(
          builder: (context, next) => NormalHomeSubScreen(),
          duration: mosqueManger.nextSalahAfter(),
          skip: mosqueManger.nextSalahAfter() > Duration(minutes: 5),
        ),
        WorkFlowItem(
          builder: (context, next) => AdhanSubScreen(onDone: next),
          skip: now.isAfter(adhanEndTime),
          minimumDuration: 2.minutes,
        ),
        WorkFlowItem(
          builder: (context, next) => AfterAdhanSubScreen(onDone: next),
          skip: now.isAfter(adhanDuaaEndTime),
          disabled: mosqueConfig.duaAfterAzanEnabled == false,
        ),
        WorkFlowItem(
          builder: (context, next) => DuaaBetweenAdhanAndIqamaaScreen(
            onDone: next,
          ),
          disabled: mosqueConfig.duaAfterAzanEnabled == false,
          duration: 30.seconds,
          skip: true,
        ),
        WorkFlowItem(
          builder: (context, next) => IqamaaCountDownSubScreen(onDone: next),
          skip: now.isAfter(currentIqamaTime),
          disabled: mosqueManger.mosqueConfig?.iqamaEnabled == false,
        ),
        WorkFlowItem(
          builder: (context, next) => IqamaSubScreen(onDone: next),
          skip: now.isAfter(iqamaEndTime),
          disabled: mosqueManger.mosqueConfig?.iqamaEnabled == false,
        ),
        WorkFlowItem(
          builder: (context, next) =>
              mosqueConfig.blackScreenWhenPraying == true
                  ? Container(color: Colors.black)
                  : NormalHomeSubScreen(),
          skip: now.isAfter(salahEndTime),
          duration: mosqueManger.currentSalahDuration,
          disabled: mosqueConfig.iqamaEnabled == false,
        ),
        WorkFlowItem(
          builder: (context, next) => AfterSalahAzkar(onDone: next),
          disabled: mosqueConfig.iqamaEnabled == false,
        ),
      ],
    );
  }
}
