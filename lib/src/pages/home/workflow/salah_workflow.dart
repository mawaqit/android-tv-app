import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/src/pages/home/sub_screens/AfterAdhanHadithSubScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/AfterSalahAzkarScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/DuaaEftarScreen.dart';
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
    if (mosqueManger.nextSalahAfter() < Duration(minutes: 5)) return mosqueManger.nextSalahIndex();

    return mosqueManger.salahIndex;
  }

  @override
  Widget build(BuildContext context) {
    final mosqueManger = context.watch<MosqueManager>();
    final mosqueConfig = mosqueManger.mosqueConfig!;

    final hijri = mosqueManger.mosqueHijriDate();

    final currentSalah = calculateCurrentSalah(mosqueManger);
    final now = mosqueManger.mosqueDate();
    final currentSalahTime = mosqueManger.actualTimes()[currentSalah];
    final currentIqamaTime = mosqueManger.actualIqamaTimes()[currentSalah];

    final adhanEndTime = currentSalahTime.add(mosqueManger.getAdhanDuration());
    final adhanDuaaEndTime = adhanEndTime.add(Duration(seconds: 35));
    final iqamaEndTime = currentIqamaTime.add(Duration(minutes: 1));
    final salahTime = mosqueManger.mosqueConfig!.duaAfterPrayerShowTimes[currentSalah];
    final salahEndTime = iqamaEndTime.add(
      Duration(minutes: int.tryParse(salahTime) ?? 0),
    );

    /// duaaAlsaym is only for magrib salah in Ramadan month
    final duaaAlsayemDuration = currentSalah == 3 && hijri.islamicMonth == 8 ? 2.minutes : 0.minutes;

    return ContinuesWorkFlowWidget(
      onDone: widget.onDone,
      workFlowItems: [
        WorkFlowItem(
          builder: (context, next) => NormalHomeSubScreen(),

          /// take [duaaAlsayemDuration] to show off duaa alsayem before the adhan
          duration: mosqueManger.nextSalahAfter() - duaaAlsayemDuration,
          skip: mosqueManger.nextSalahAfter() > Duration(minutes: 5) ||
              mosqueManger.nextSalahAfter() < duaaAlsayemDuration,
        ),
        WorkFlowItem(
          builder: (context, next) => DuaaEftarScreen(),

          /// the duration is the minimum between the remaining time to the next salah and the duaa alsayem duration
          /// if the user open the screen during this time he will not waite until it end
          /// it will be forced to end in the adhan time
          duration: min(duaaAlsayemDuration.inMilliseconds, mosqueManger.nextSalahAfter().inMilliseconds).milliseconds,
          skip: mosqueManger.nextSalahAfter() > duaaAlsayemDuration,
          disabled: currentSalah != 3 || mosqueManger.mosqueHijriDate().islamicMonth != 8,
        ),
        WorkFlowItem(
          builder: (context, next) => AdhanSubScreen(onDone: next),
          skip: now.isAfter(adhanEndTime),
          minimumDuration: mosqueManger.isShortIqamaDuration(currentSalah) ? 90.seconds : 150.seconds,
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
          skip: true,
        ),
        WorkFlowItem(
          builder: (context, next) => IqamaaCountDownSubScreen(onDone: next),
          skip: now.isAfter(currentIqamaTime),
          disabled: mosqueManger.mosqueConfig?.iqamaEnabled == false,
        ),
        WorkFlowItem(
          builder: (context, next) => IqamaSubScreen(),
          duration: Duration(seconds: mosqueConfig.iqamaDisplayTime ?? 30),
          skip: now.isAfter(iqamaEndTime),
          disabled: mosqueManger.mosqueConfig?.iqamaEnabled == false,
        ),
        WorkFlowItem(
          builder: (context, next) =>
              mosqueConfig.blackScreenWhenPraying == true ? Container(color: Colors.black) : NormalHomeSubScreen(),
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
