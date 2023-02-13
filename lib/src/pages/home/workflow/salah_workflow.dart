import 'package:flutter/material.dart';
import 'package:mawaqit/src/enum/home_active_screen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/AdhanSubScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/AfterAdhanHadithSubScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/AfterSalahAzkarScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/IqamaSubScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/IqamaaCountDownSubScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/normal_home.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

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
  SalahWorkflowScreens state = SalahWorkflowScreens.normal;

  /// user entered after iqama + salah time
  /// user entered after iqama + salah time + azkar time
  ///
  calcFirstScreen() {
    final mosqueManger = context.read<MosqueManager>();
    final currentSalah = calculateCurrentSalah(mosqueManger);

    final now = mosqueManger.mosqueDate();
    final currentSalahTime = mosqueManger.actualTimes()[currentSalah];
    final currentIqamaTime = mosqueManger.actualIqamaTimes()[currentSalah];

    final adhanEndTime = currentSalahTime.add(mosqueManger.getAdhanDuration());
    final adhanDuaaEndTime = adhanEndTime.add(Duration(seconds: 35));
    final iqamaEndTime = currentIqamaTime.add(Duration(minutes: 1));
    final salahTime =
        mosqueManger.mosqueConfig!.duaAfterPrayerShowTimes[currentSalah];
    final salahEndTime =
        iqamaEndTime.add(Duration(minutes: int.tryParse(salahTime) ?? 0));

    if (mosqueManger.mosqueConfig?.iqamaEnabled == false &&
        now.isAfter(adhanDuaaEndTime)) {
      widget.onDone();
    }

    if (now.isAfter(salahEndTime)) return onSalahTimeDoneDone();

    if (now.isAfter(iqamaEndTime)) return onIqamaaDone();

    if (now.isAfter(currentIqamaTime)) return onIqamaaCountDownDone();

    if (now.isAfter(adhanDuaaEndTime)) return onAfterAdhanDuaaDone();

    if (now.isAfter(adhanEndTime)) return onAdhanDone();

    return showAdhan(
      mosqueManger.nextSalahAfter() > Duration(minutes: 5)
          ? Duration.zero
          : mosqueManger.nextSalahAfter(),
    );
  }

  calculateCurrentSalah(MosqueManager mosqueManger) {
    if (mosqueManger.nextSalahAfter() < Duration(minutes: 5))
      return mosqueManger.nextSalahIndex();

    return mosqueManger.salahIndex;
  }

  showAdhan(Duration after) {
    Future.delayed(after, () {
      if (mounted) {
        setState(() => state = SalahWorkflowScreens.adhan);
      }
    });
  }

  onAdhanDone() => setState(() => state = SalahWorkflowScreens.afterAdhanDuaa);

  onAfterAdhanDuaaDone() {
    final mosqueManager = context.read<MosqueManager>();
    if (mosqueManager.mosqueConfig?.iqamaEnabled == false)
      return widget.onDone();

    setState(() => state = SalahWorkflowScreens.iqamaaCountDown);
  }

  onIqamaaCountDownDone() =>
      setState(() => state = SalahWorkflowScreens.iqamaa);

  onIqamaaDone() {
    setState(() => state = SalahWorkflowScreens.salahTime);

    Future.delayed(context.read<MosqueManager>().currentSalahDuration,
        onSalahTimeDoneDone);
  }

  onSalahTimeDoneDone() =>
      setState(() => state = SalahWorkflowScreens.afterSalahAzkar);

  @override
  void initState() {
    calcFirstScreen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case SalahWorkflowScreens.normal:
        return NormalHomeSubScreen();
      case SalahWorkflowScreens.adhan:
        return AdhanSubScreen(onDone: onAdhanDone);
      case SalahWorkflowScreens.afterAdhanDuaa:
        return AfterAdhanSubScreen(onDone: onAfterAdhanDuaaDone);
      case SalahWorkflowScreens.iqamaaCountDown:
        return IqamaaCountDownSubScreen(onDone: onIqamaaCountDownDone);
      case SalahWorkflowScreens.iqamaa:
        return IqamaSubScreen(onDone: onIqamaaDone);
      case SalahWorkflowScreens.salahTime:
        return Scaffold(backgroundColor: Colors.black);
      case SalahWorkflowScreens.afterSalahAzkar:
        return AfterSalahAzkar(onDone: widget.onDone);
    }
  }
}
