import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/repaint_boundires.dart';
import 'package:mawaqit/src/pages/home/widgets/SalahItem.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

/// the bottom bar of 5 salah times
class SalahTimesBar extends StatelessWidget {
  const SalahTimesBar({
    Key? key,
    this.miniStyle = false,
    this.microStyle = false,
  }) : super(key: key);

  final bool miniStyle;
  final bool microStyle;

  @override
  Widget build(BuildContext context) {
    final mosqueProvider = context.watch<MosqueManager>();

    final nextActiveIqama = mosqueProvider.nextIqamaIndex();

    final todayTimes = mosqueProvider.useTomorrowTimes
        ? mosqueProvider.tomorrowTimes
        : mosqueProvider.todayTimes;

    final todayIqama = mosqueProvider.useTomorrowTimes
        ? mosqueProvider.tomorrowIqama
        : mosqueProvider.todayIqama;

    final tr = S.of(context);

    final step = Duration(milliseconds: 100);
    final duration = Duration(milliseconds: 300);

    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 3.vw),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SalahItemWidget(
              title: miniStyle ? null : tr.fajr,
              time: todayTimes[0],
              iqama: microStyle ? null : todayIqama[0],
              active: nextActiveIqama == 0,
              withDivider: false,
            )
                .animate()
                .fadeIn(duration: duration)
                .slideY(begin: 1, duration: duration)
                .addRepaintBoundary(),
            SalahItemWidget(
              title: miniStyle ? null : tr.duhr,
              time: todayTimes[1],
              iqama: microStyle ? null : todayIqama[1],
              active: nextActiveIqama == 1 &&
                  (mosqueProvider.mosqueDate().weekday != DateTime.friday ||
                      mosqueProvider.jumuaTime == null ||
                      !mosqueProvider.typeIsMosque),
              withDivider: false,
            )
                .animate(delay: step)
                .fadeIn(duration: duration)
                .slideY(begin: 1, duration: duration),
            SalahItemWidget(
              title: miniStyle ? null : tr.asr,
              time: todayTimes[2],
              iqama: microStyle ? null : todayIqama[2],
              active: nextActiveIqama == 2,
              withDivider: false,
            )
                .animate(delay: step * 2)
                .fadeIn(duration: duration)
                .slideY(begin: 1, duration: duration),
            SalahItemWidget(
              title: miniStyle ? null : tr.maghrib,
              time: todayTimes[3],
              iqama: microStyle ? null : todayIqama[3],
              active: nextActiveIqama == 3,
              withDivider: false,
            )
                .animate(delay: step * 3)
                .fadeIn(duration: duration)
                .slideY(begin: 1, duration: duration),
            SalahItemWidget(
              title: miniStyle ? null : tr.isha,
              time: todayTimes[4],
              iqama: microStyle ? null : todayIqama[4],
              active: nextActiveIqama == 4,
              withDivider: false,
            )
                .animate(delay: step * 4)
                .fadeIn(duration: duration)
                .slideY(begin: 1, duration: duration),
          ],
        ),
      ),
    );
  }
}
