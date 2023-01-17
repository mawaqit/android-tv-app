import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mawaqit/src/enum/home_active_screen.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/pages/home/sub_screens/AdhanSubScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/AnnouncementScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/RandomHadithScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/normal_home.dart';
import 'package:mawaqit/src/pages/home/widgets/mosque_background_screen.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

const _HadithDuration = Duration(minutes: 1);
const _HadithRepeatDuration = Duration(minutes: 4);
const _AnnouncementRepeatDuration = Duration(minutes: 8);

/// show the [NormalHomeSubScreen][AnnouncementScreen][RandomHadithScreen]
class NormalWorkflowScreen extends StatefulWidget {
  const NormalWorkflowScreen({Key? key}) : super(key: key);

  @override
  State<NormalWorkflowScreen> createState() => _NormalWorkflowScreenState();
}

class _NormalWorkflowScreenState extends State<NormalWorkflowScreen> {
  NormalWorkflowScreens state = NormalWorkflowScreens.normal;
  int announcementIndex = 0;

  Future? nextSalahFuture;
  Future? beforeFajrFuture;
  Timer? randomHadithTimer;
  Timer? announcementsTimer;

  void backToHome() {
    if (mounted) {
      setState(() {
        state = NormalWorkflowScreens.normal;
      });
    }
  }

  beforeFajrWakeupHandler() {
    beforeFajrFuture?.ignore();
    final mosqueManager = context.read<MosqueManager>();

    if (mosqueManager.mosqueConfig?.wakeForFajrTime == true) {
      var beforeFajrTime = mosqueManager.actualTimes()[0].subtract(kAdhanBeforeFajrDuration);

      if (beforeFajrTime.isBefore(mosqueManager.mosqueDate())) beforeFajrTime = beforeFajrTime.add(Duration(days: 1));

      print(beforeFajrTime.difference(mosqueManager.mosqueDate()));

      print('register before fajr adhan in ${beforeFajrTime.difference(mosqueManager.mosqueDate())}');
      beforeFajrFuture = Future.delayed(beforeFajrTime.difference(mosqueManager.mosqueDate()));

      beforeFajrFuture?.then((value) => showBeforeFajrAdhan());
    }
  }

  /// show the wakeup adhan before fajr
  showBeforeFajrAdhan() {
    if (!mounted) return;

    AppRouter.push(MosqueBackgroundScreen(
      child: AdhanSubScreen(
        forceAdhan: true,
        onDone: () => Navigator.pop(context),
      ),
    ));
  }

  /// this function will trigger the next salah workflow
  nextSalahHandler() {
    nextSalahFuture?.ignore();

    final mosqueManager = context.read<MosqueManager>();

    nextSalahFuture = Future.delayed(mosqueManager.nextSalahAfter() - Duration(minutes: 5));
    nextSalahFuture?.then((value) => mosqueManager.startSalahWorkflow());
  }

  /// show hadith each 4min
  void randomHadithHandler() {
    randomHadithTimer?.cancel();

    randomHadithTimer = Timer.periodic(_HadithRepeatDuration, (i) {
      if (mounted && state == NormalWorkflowScreens.normal) {
        setState(() {
          state = NormalWorkflowScreens.randomHadith;
        });
      }

      /// back to normal home after 1 min
      Future.delayed(_HadithDuration, backToHome);
    });
  }

  /// show new announcement each 8 min
  void announcementHandler() {
    announcementsTimer?.cancel();

    announcementsTimer = Timer.periodic(_AnnouncementRepeatDuration, (i) {
      if (mounted && state == NormalWorkflowScreens.normal) {
        setState(() {
          state = NormalWorkflowScreens.announcement;
          announcementIndex = i.tick;
        });
      }
    });
  }

  @override
  void initState() {
    randomHadithHandler();
    announcementHandler();
    nextSalahHandler();
    beforeFajrWakeupHandler();

    super.initState();
  }

  @override
  void dispose() {
    randomHadithTimer?.cancel();
    announcementsTimer?.cancel();
    nextSalahFuture?.ignore();
    beforeFajrFuture?.ignore();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case NormalWorkflowScreens.normal:
        return NormalHomeSubScreen();
      case NormalWorkflowScreens.announcement:
        return AnnouncementScreen(
          index: announcementIndex,
          onDone: backToHome,
        );
      case NormalWorkflowScreens.randomHadith:
        return RandomHadithScreen();
    }
  }
}
