import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/src/pages/home/workflow/jumua_workflow_screen.dart';
import 'package:mawaqit/src/pages/home/workflow/normal_workflow.dart';
import 'package:mawaqit/src/pages/home/workflow/salah_workflow.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

import '../../../helpers/AppDate.dart';
import '../../../helpers/TimeShiftManager.dart';
import '../../../services/FeatureManager.dart';
import '../widgets/workflows/repeating_workflow_widget.dart';

/// this is the main workflow of the app
/// which is responsible for showing the correct workflow [NormalWorkflowScreen] or [JumuaaWorkflowScreen] or [SalahWorkflowScreen]
class AppWorkflowScreen extends StatelessWidget {
  const AppWorkflowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.watch<MosqueManager>();
    final now = AppDateTime.now();
    final TimeShiftManager timeManager = TimeShiftManager();
    final featureManager = Provider.of<FeatureManager>(context);

    ValueKey? key;

    if (featureManager.isFeatureEnabled("timezone_shift") &&
        timeManager.deviceModel == "MAWABOX" &&
        timeManager.isLauncherInstalled) {
      key = ValueKey('${timeManager.shift}_${timeManager.shiftInMinutes}');
    }
    final times =
        mosqueManager.useTomorrowTimes ? mosqueManager.actualTimes(now.add(1.days)) : mosqueManager.actualTimes(now);

    final iqama = mosqueManager.useTomorrowTimes
        ? mosqueManager.actualIqamaTimes(now.add(1.days))
        : mosqueManager.actualIqamaTimes(now);

    return RepeatingWorkFlowWidget(
      key: key,
      debugName: "App workflow",
      child: NormalWorkflowScreen(),
      items: [
        ...times.mapIndexed((index, elem) => RepeatingWorkflowItem(
              debugName: 'SalahWorkflowScreen $index',
              builder: (context, next) => SalahWorkflowScreen(onDone: next),
              repeatingDuration: 1.days,

              dateTime: elem.add(-5.minutes),

              /// auto start Workflow if user starts the app during the Salah time
              /// give 4 minute for the salah and 2 for azkar
              showInitial: () => now.isAfter(elem.add(-5.minutes)) && now.isBefore(iqama[index].add(6.minutes)),

              // dateTime: e,
              // disable Duhr if it's Friday
              disabled: index == 1 && now.weekday == DateTime.friday,
            )),

        // Jumuaa Workflow
        RepeatingWorkflowItem(
          debugName: 'JumuaaWorkflowScreen',
          builder: (context, next) => JumuaaWorkflowScreen(onDone: next),
          repeatingDuration: 7.days,
          dateTime: mosqueManager.activeJumuaaDate(),
          showInitial: () {
            final activeJumuaaDate = mosqueManager.activeJumuaaDate();

            if (now.isBefore(activeJumuaaDate)) return false;

            /// If user opens the app during the Jumuaa time then show the Jumuaa workflow
            /// give 30 minutes for the Jumuaa
            return now
                .isBefore(activeJumuaaDate.add(Duration(minutes: mosqueManager.mosqueConfig!.jumuaTimeout ?? 30)));
          },
        ),
      ],
    );
  }
}
