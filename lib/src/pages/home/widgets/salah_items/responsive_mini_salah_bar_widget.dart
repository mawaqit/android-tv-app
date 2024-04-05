import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/AppDate.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/repaint_boundaries.dart';
import 'package:mawaqit/src/pages/home/widgets/orientation_widget.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/SalahItem.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/mini_horizontal_salah_item.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

/// salah item animation step duration
const _step = Duration(milliseconds: 100);

/// salah item animation duration
const _duration = Duration(milliseconds: 300);

/// used on secondary screens to show salah bar in a smaller size
class ResponsiveMiniSalahBarWidget extends StatelessOrientationWidget {
  const ResponsiveMiniSalahBarWidget({super.key, this.activeItem});

  /// used to force salah item to be active
  /// if null, will be calculated based on next iqama
  final int? activeItem;

  @override
  Widget buildLandscape(BuildContext context) {
    final mosqueProvider = context.watch<MosqueManager>();
    final nextActiveIqama = activeItem ?? mosqueProvider.nextIqamaIndex();

    final times = mosqueProvider.times!;
    final now = AppDateTime.now();
    final todayTimes = mosqueProvider.useTomorrowTimes
        ? times.dayTimesStrings(now.add(1.days), salahOnly: false)
        : times.dayTimesStrings(now, salahOnly: false);
    final iqamas = mosqueProvider.times!.dayIqamaStrings(now);

    final turkishImask = todayTimes.length == 7 ? todayTimes.removeAt(0) : null;
    todayTimes.removeAt(1);
    final isIqamaMoreImportant =
        mosqueProvider.mosqueConfig!.iqamaMoreImportant == true;

    /// on jumuaa we disable duhr highlight for mosques only
    bool duhrHighlightDisable =
        mosqueProvider.mosqueDate().weekday == DateTime.friday &&
            mosqueProvider.typeIsMosque;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.vw),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (turkishImask != null)
            SalahItemWidget(
                    removeBackground: true,
                    time: turkishImask,
                    isIqamaMoreImportant: isIqamaMoreImportant)
                .animate()
                .fadeIn(duration: _duration)
                .slideY(begin: 1, duration: _duration, curve: Curves.easeOut)
                .addRepaintBoundary(),
          for (var i = 0; i < 5; i++)
            SalahItemWidget(
                    withDivider: false,
                    iqama: iqamas[i],
                    time: todayTimes[i],
                    active: i == 1
                        ? nextActiveIqama == i && !duhrHighlightDisable
                        : nextActiveIqama == i,
                    isIqamaMoreImportant: isIqamaMoreImportant)
                .animate(delay: _step * (i + 1))
                .fadeIn(duration: _duration)
                .slideY(begin: 1, duration: _duration, curve: Curves.easeOut)
                .addRepaintBoundary(),
        ],
      ),
    );
  }

  @override
  Widget buildPortrait(BuildContext context) {
    final mosqueProvider = context.watch<MosqueManager>();
    final nextActiveIqama = activeItem ?? mosqueProvider.nextIqamaIndex();

    final times = mosqueProvider.times!;
    final now = AppDateTime.now();
    final todayTimes = mosqueProvider.useTomorrowTimes
        ? times.dayTimesStrings(now.add(1.days), salahOnly: false)
        : times.dayTimesStrings(now, salahOnly: false);
    final iqamas = mosqueProvider.times!.dayIqamaStrings(now);
    final isIqamaMoreImportant =
        mosqueProvider.mosqueConfig!.iqamaMoreImportant == true;
    final turkishImask = todayTimes.length == 7 ? todayTimes.removeAt(0) : null;
    todayTimes.removeAt(1);

    /// on jumuaa we disable duhr highlight for mosques only
    bool duhrHighlightDisable =
        AppDateTime.isFriday && mosqueProvider.typeIsMosque;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 1.vh),
      child: Wrap(
        spacing: 5.vh,
        runSpacing: 2.vw,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.center,
        children: [
          if (turkishImask != null)
            SizedBox(
              width: 30.vw,
              child: MiniHorizontalSalahItem(
                title: S.of(context).imsak,
                time: turkishImask,
              )
                  .animate()
                  .fadeIn(duration: _duration)
                  .slideY(begin: 1, duration: _duration, curve: Curves.easeOut)
                  .addRepaintBoundary(),
            ),
          for (var i = 0; i < 5; i++)
            SizedBox(
              width: 25.vw,
              child: SalahItemWidget(
                      withDivider: false,
                      iqama: iqamas[i],
                      time: todayTimes[i],
                      active: i == 1
                          ? nextActiveIqama == i && !duhrHighlightDisable
                          : nextActiveIqama == i,
                      isIqamaMoreImportant: isIqamaMoreImportant)
                  .animate(delay: _step * (i + 1))
                  .fadeIn(duration: _duration)
                  .slideY(begin: 1, duration: _duration, curve: Curves.easeOut)
                  .addRepaintBoundary(),
            ),
        ],
      ),
      
    );
  }
}
