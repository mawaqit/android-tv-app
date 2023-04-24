import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/src/enum/home_active_screen.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/pages/home/sub_screens/AnnouncementScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/RandomHadithScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/fajr_wake_up_screen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/normal_home.dart';
import 'package:mawaqit/src/pages/home/sub_screens/takberat_aleid_screen.dart';
import 'package:mawaqit/src/pages/home/widgets/mosque_background_screen.dart';
import 'package:mawaqit/src/pages/home/widgets/workflows/repeating_workflow_widget.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

const _HadithDuration = Duration(seconds: 90);
const _HadithRepeatDuration = Duration(minutes: 4);
const _AnnouncementRepeatDuration = Duration(minutes: 8);

/// show the [NormalHomeSubScreen][AnnouncementScreen][RandomHadithScreen]
class NormalWorkflowScreen extends StatefulWidget {
  const NormalWorkflowScreen({Key? key}) : super(key: key);

  @override
  State<NormalWorkflowScreen> createState() => _NormalWorkflowScreenState();
}

class _NormalWorkflowScreenState extends State<NormalWorkflowScreen> {
  Future? nextSalahFuture;

  /// this function will trigger the next salah workflow
  nextSalahHandler() {
    nextSalahFuture?.ignore();

    final mosqueManager = context.read<MosqueManager>();

    nextSalahFuture = Future.delayed(mosqueManager.nextSalahAfter() - Duration(minutes: 5));
    nextSalahFuture?.then((value) => mosqueManager.startSalahWorkflow());
  }

  @override
  void initState() {
    nextSalahHandler();

    super.initState();
  }

  @override
  void dispose() {
    nextSalahFuture?.ignore();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.watch<MosqueManager>();

    return RepeatingWorkFlowWidget(
      child: NormalHomeSubScreen(),
      items: [
        /// announcement screen
        RepeatingWorkflowItem(
          builder: (context, next) => AnnouncementScreen(
            onDone: next,
            enableVideos: !mosqueManager.typeIsMosque,
          ),
          repeatingDuration: _AnnouncementRepeatDuration,
        ),

        /// random hadith screen
        RepeatingWorkflowItem(
          builder: (context, next) => RandomHadithScreen(),
          repeatingDuration: _HadithRepeatDuration,
          disabled: !mosqueManager.isOnline ||
              mosqueManager.isDisableHadithBetweenSalah() ||
              !mosqueManager.mosqueConfig!.randomHadithEnabled,
          duration: _HadithDuration,
        ),

        /// before fajr wakeup adhan
        RepeatingWorkflowItem(
          builder: (context, next) => FajrWakeUpSubScreen(onDone: next),
          dateTime: mosqueManager.actualTimes()[0].subtract(
                Duration(minutes: mosqueManager.mosqueConfig!.wakeForFajrTime ?? 0),
              ),
          repeatingDuration: Duration(days: 1),
          disabled: mosqueManager.mosqueConfig!.wakeForFajrTime == null,

          /// this item will discard any active item and show on the screen
          forceStart: true,
        ),

        /// Takberat al eid screen
        RepeatingWorkflowItem(
          builder: (context, next) => TakberatAleidScreen(),
          dateTime: mosqueManager.actualTimes()[0].add(1.hours),
          endTime: mosqueManager.actualTimes()[0].add(3.hours),
          disabled: !mosqueManager.isEidFirstDay,
          forceStart: true,
          showInitial: () {
            final now = mosqueManager.mosqueDate();

            final differece = now.difference(mosqueManager.actualTimes()[0]);

            return differece > 1.hours && differece < 3.hours;
          },
        ),
      ],
    );
  }
}
