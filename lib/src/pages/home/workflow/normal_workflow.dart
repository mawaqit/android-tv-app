import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/pages/home/sub_screens/AnnouncementScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/RandomHadithScreen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/fajr_wake_up_screen.dart';
import 'package:mawaqit/src/pages/home/sub_screens/normal_home.dart';
import 'package:mawaqit/src/pages/home/sub_screens/takberat_aleid_screen.dart';
import 'package:mawaqit/src/pages/home/widgets/workflows/repeating_workflow_widget.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:mawaqit/src/state_management/random_hadith/random_hadith_notifier.dart';
import 'package:provider/provider.dart';

const _HadithDuration = Duration(seconds: 90);
const _HadithRepeatDuration = Duration(minutes: 4);
const _AnnouncementRepeatDuration = Duration(minutes: 8);

/// show the [NormalHomeSubScreen][AnnouncementScreen][RandomHadithScreen]
class NormalWorkflowScreen extends ConsumerStatefulWidget {
  const NormalWorkflowScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NormalWorkflowScreen> createState() => _NormalWorkflowScreenState();
}

class _NormalWorkflowScreenState extends ConsumerState<NormalWorkflowScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final mosqueManager = context.read<MosqueManager>();
      ref.read(randomHadithNotifierProvider.notifier).ensureHadithLanguage(mosqueManager);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.watch<MosqueManager>();
    final userPrefs = context.watch<UserPreferencesManager>();

    return RepeatingWorkFlowWidget(
      child: NormalHomeSubScreen(),
      items: [
        /// announcement screen
        RepeatingWorkflowItem(
          builder: (context, next) => AnnouncementScreen(
            onDone: next,
            enableVideos: !mosqueManager.typeIsMosque || userPrefs.isSecondaryScreen,
          ),
          repeatingDuration: _AnnouncementRepeatDuration,
        ),

        /// random hadith screen
        RepeatingWorkflowItem(
          builder: (context, next) => RandomHadithScreen(onDone: next),
          repeatingDuration: _HadithRepeatDuration,
          disabled: mosqueManager.isDisableHadithBetweenSalah() || !mosqueManager.mosqueConfig!.randomHadithEnabled,
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
          disabled: !mosqueManager.isEidFirstDay(userPrefs.hijriAdjustments),
          forceStart: true,
          showInitial: () {
            final now = mosqueManager.mosqueDate();

            final difference = now.difference(mosqueManager.actualTimes()[0]);

            return difference > 1.hours && difference < 3.hours;
          },
        ),
      ],
    );
  }
}
