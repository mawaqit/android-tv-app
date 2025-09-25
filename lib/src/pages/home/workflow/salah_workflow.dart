import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/models/calendar/MawaqitHijriCalendar.dart';
import 'package:mawaqit/src/pages/home/sub_screens/AfterAdhanHadithSubScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/AfterSalahAzkarScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/DuaaBetweenAdhanAndIqama.dart';
import 'package:mawaqit/src/pages/home/sub_screens/DuaaEftarScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/IqamaSubScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/IqamaaCountDownSubScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/normal_home.dart';
import 'package:mawaqit/src/pages/home/widgets/workflows/repeating_workflow_widget.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';

import '../sub_screens/AdhanSubScreen.dart';
import '../widgets/workflows/WorkFlowWidget.dart';

/// handling the logic form 5min before adhan -> the last of after salah azkar
class SalahWorkflowScreen extends ConsumerStatefulWidget {
  const SalahWorkflowScreen({
    Key? key,
    required this.onDone,
  }) : super(key: key);

  /// when the workflow is finished
  final void Function() onDone;

  @override
  ConsumerState<SalahWorkflowScreen> createState() => _SalahWorkflowScreenState();
}

class _SalahWorkflowScreenState extends ConsumerState<SalahWorkflowScreen> {
  // Changed to ConsumerState
  @override
  void initState() {
    super.initState();
  }

  calculateCurrentSalah(MosqueManager mosqueManger) {
    if (mosqueManger.nextSalahAfter() < Duration(minutes: 5)) return mosqueManger.nextSalahIndex();

    return mosqueManger.salahIndex;
  }

  Widget beforeSalahTime(
    MosqueManager mosqueManger,
    int currentSalah,
    MawaqitHijriCalendar hijri,
  ) {
    final currentSalahTime = mosqueManger.actualTimes()[currentSalah];
    return RepeatingWorkFlowWidget(
      child: NormalHomeSubScreen(),
      items: [
        /// duaa alsayem in ramadan
        RepeatingWorkflowItem(
          builder: (context, next) => DuaaEftarScreen(),
          duration: 90.seconds,
          dateTime: currentSalahTime.add(-2.minutes),
          showInitial: () => mosqueManger.nextSalahAfter() < 2.minutes,

          /// show only in ramadan and magrib salah
          disabled: currentSalah != 3 || hijri.islamicMonth != 8,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mosqueManger = context.watch<MosqueManager>();
    final mosqueConfig = mosqueManger.mosqueConfig!;
    final userPrefs = context.watch<UserPreferencesManager>();

    final hijri = mosqueManger.mosqueHijriDate(userPrefs.hijriAdjustments);

    final currentSalah = calculateCurrentSalah(mosqueManger);
    final now = mosqueManger.mosqueDate();
    final currentSalahTime = mosqueManger.actualTimes()[currentSalah];
    final currentIqamaTime = mosqueManger.actualIqamaTimes()[currentSalah];
    final isFajrPray = mosqueManger.salahIndex == 0;
    final isAsrPray = mosqueManger.salahIndex == 2;
    final iqamaEndTime = currentIqamaTime.add(Duration(minutes: 1));
    final salahTime = mosqueManger.mosqueConfig!.duaAfterPrayerShowTimes[currentSalah];
    final salahEndTime = iqamaEndTime.add(
      Duration(minutes: int.tryParse(salahTime) ?? 0),
    );

    return ContinuesWorkFlowWidget(
      onDone: widget.onDone,
      workFlowItems: [
        /// before the adhan time
        WorkFlowItem(
          duration: mosqueManger.nextSalahAfter(),
          skip: mosqueManger.nextSalahAfter() > Duration(minutes: 6),
          builder: (context, next) => beforeSalahTime(mosqueManger, currentSalah, hijri),
        ),
        WorkFlowItem(
          builder: (context, next) => AdhanSubScreen(onDone: next),
        ),
        WorkFlowItem(
          builder: (context, next) => AfterAdhanSubScreen(onDone: next),
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
          builder: (context, next) => IqamaaCountDownSubScreen(
            onDone: next,
            currentSalahIndex: currentSalah,
          ),
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
        WorkFlowItem(
            duration: kAzkarDuration,
            builder: (context, next) => AfterSalahAzkar(

                /// this is a redundant parameter as it is always should be (isFajrPray | isAsrPray)
                isAfterAsrOrFajr: true,
                isAfterAsr: isAsrPray,
                azkarTitle: isFajrPray ? AzkarConstant.kAzkarSabahAfterPrayer : AzkarConstant.kAzkarAsrAfterPrayer),
            disabled: mosqueConfig.iqamaEnabled == false || (!isFajrPray && !isAsrPray)),
      ],
    );
  }
}
