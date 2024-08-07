import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/pages/home/OfflineHomeScreen.dart';
import 'package:mawaqit/src/pages/home/workflow/jumua_workflow_screen.dart';
import 'package:mawaqit/src/pages/home/workflow/normal_workflow.dart';
import 'package:mawaqit/src/pages/home/workflow/salah_workflow.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/state_management/quran/recite/quran_audio_player_notifier.dart';
import 'package:mawaqit/src/state_management/widget_routing/current_widget_notifier.dart';
import 'package:provider/provider.dart' as provider;

import '../../../helpers/AppDate.dart';
import '../../../helpers/TimeShiftManager.dart';
import '../../../services/FeatureManager.dart';
import '../widgets/workflows/repeating_workflow_widget.dart';

final currentTimeProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(const Duration(minutes: 1), (_) => AppDateTime.now());
});

class AppWorkflowScreen extends ConsumerStatefulWidget {
  const AppWorkflowScreen({super.key});

  @override
  _AppWorkflowScreenState createState() => _AppWorkflowScreenState();
}

class _AppWorkflowScreenState extends ConsumerState<AppWorkflowScreen> {
  Timer? _timer;
  DateTime? _nextCheckTime;
  bool _hasExited = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _scheduleNextCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _scheduleNextCheck() {
    final mosqueManager =
        provider.Provider.of<MosqueManager>(context, listen: false);
    final now = AppDateTime.now();
    final times = mosqueManager.useTomorrowTimes
        ? mosqueManager.actualTimes(now.add(const Duration(days: 1)))
        : mosqueManager.actualTimes(now);

    DateTime nextTime = times.firstWhere(
      (time) => time.isAfter(now),
      orElse: () => times.first.add(const Duration(days: 1)),
    );

    _nextCheckTime = nextTime.subtract(const Duration(minutes: 10));

    if (_nextCheckTime!.isBefore(now)) {
      _nextCheckTime = now.add(const Duration(seconds: 1));
    }

    _timer?.cancel();
    _timer = Timer(_nextCheckTime!.difference(now), _checkQuranBackgroundExit);
  }

  void _checkQuranBackgroundExit() {
    final now = AppDateTime.now();
    if (now.isAfter(_nextCheckTime!)) {
      final currentWidget = ref.read(currentWidgetProvider);
      if (currentWidget == "QuranBackground" && !_hasExited) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(seconds: 5), () {
          if (!_hasExited) {
            _hasExited = true;
            print("Exiting Quran mode");
            WidgetsBinding.instance.addPostFrameCallback((_) {
              AppRouter.pushReplacement(OfflineHomeScreen());
              ref.read(quranPlayerNotifierProvider.notifier).pause();
            });
          }
        });
      }
    }
    _scheduleNextCheck();
  }

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.watch<MosqueManager>();
    final now = ref.watch(currentTimeProvider).when(
          data: (time) => time,
          loading: () => AppDateTime.now(),
          error: (_, __) => AppDateTime.now(),
        );
    final TimeShiftManager timeManager = TimeShiftManager();
    final featureManager = provider.Provider.of<FeatureManager>(context);

    ValueKey? key;

    if (featureManager.isFeatureEnabled("timezone_shift") &&
        timeManager.deviceModel == "MAWABOX" &&
        timeManager.isLauncherInstalled) {
      key = ValueKey('${timeManager.shift}_${timeManager.shiftInMinutes}');
    }

    final times = mosqueManager.useTomorrowTimes
        ? mosqueManager.actualTimes(now.add(const Duration(days: 1)))
        : mosqueManager.actualTimes(now);

    final iqama = mosqueManager.useTomorrowTimes
        ? mosqueManager.actualIqamaTimes(now.add(const Duration(days: 1)))
        : mosqueManager.actualIqamaTimes(now);

    return RepeatingWorkFlowWidget(
      key: key,
      debugName: "App workflow",
      child: NormalWorkflowScreen(),
      items: [
        ...times.mapIndexed((index, elem) => RepeatingWorkflowItem(
              debugName: 'SalahWorkflowScreen $index',
              builder: (context, next) => SalahWorkflowScreen(onDone: next),
              repeatingDuration: const Duration(days: 1),
              dateTime: elem.add(const Duration(minutes: -5)),
              showInitial: () =>
                  now.isAfter(elem.add(const Duration(minutes: -5))) &&
                  now.isBefore(iqama[index].add(const Duration(minutes: 6))),
              disabled: index == 1 && now.weekday == DateTime.friday,
            )),
        RepeatingWorkflowItem(
          debugName: 'JumuaaWorkflowScreen',
          builder: (context, next) => JumuaaWorkflowScreen(onDone: next),
          repeatingDuration: const Duration(days: 7),
          dateTime: mosqueManager.activeJumuaaDate(),
          showInitial: () {
            final activeJumuaaDate = mosqueManager.activeJumuaaDate();
            if (now.isBefore(activeJumuaaDate)) return false;
            return now.isBefore(activeJumuaaDate.add(Duration(
                minutes: mosqueManager.mosqueConfig!.jumuaTimeout ?? 30)));
          },
        ),
      ],
    );
  }
}
