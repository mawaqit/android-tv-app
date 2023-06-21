import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/repaint_boundaries.dart';
import 'package:mawaqit/src/pages/home/widgets/orientation_widget.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/SalahItem.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/horizontal_salah_item.dart';
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

    final todayTimes = mosqueProvider.salahBarTimes();

    /// on jumuaa we disable duhr highlight for mosques only
    bool duhrHighlightDisable = mosqueProvider.mosqueDate().weekday == DateTime.friday && mosqueProvider.typeIsMosque;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.vw),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < 5; i++)
            SalahItemWidget(
              time: todayTimes[i],
              active: i == 1 ? nextActiveIqama == i && !duhrHighlightDisable : nextActiveIqama == i,
            )
                .animate(delay: _step * i)
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

    final todayTimes = mosqueProvider.salahBarTimes();

    /// on jumuaa we disable duhr highlight for mosques only
    bool duhrHighlightDisable = mosqueProvider.mosqueDate().weekday == DateTime.friday && mosqueProvider.typeIsMosque;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 1.vh),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // top three salah item (fajr, duhr, asr)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < 3; i++)
                Expanded(
                  child: MiniHorizontalSalahItem(
                    title: mosqueProvider.salahName(i),
                    time: todayTimes[i],
                    active: i == 1 ? nextActiveIqama == i && !duhrHighlightDisable : nextActiveIqama == i,
                  )
                      .animate(delay: _step * i)
                      .fadeIn(duration: _duration)
                      .slideY(begin: 1, duration: _duration, curve: Curves.easeOut)
                      .addRepaintBoundary(),
                ),
            ],
          ),
          Row(
            children: [
              Spacer(),
              Expanded(
                flex: 2,
                child: MiniHorizontalSalahItem(
                  title: mosqueProvider.salahName(3),
                  time: todayTimes[3],
                  active: nextActiveIqama == 3,
                )
                    .animate(delay: _step * 3)
                    .fadeIn(duration: _duration)
                    .slideY(begin: 1, duration: _duration, curve: Curves.easeOut)
                    .addRepaintBoundary(),
              ),
              Expanded(
                flex: 2,
                child: HorizontalSalahItem(
                  margin: EdgeInsets.all(1.vw),
                  title: mosqueProvider.salahName(4),
                  time: todayTimes[4],
                  active: nextActiveIqama == 4,
                  withDivider: false,
                  removeBackground: false,
                  showIqama: mosqueProvider.mosqueConfig?.iqamaEnabled == true,
                  isIqamaMoreImportant: mosqueProvider.mosqueConfig?.iqamaMoreImportant ?? false,
                )
                    .animate(delay: _step * 4)
                    .fadeIn(duration: _duration)
                    .slideY(begin: 1, duration: _duration, curve: Curves.easeOut)
                    .addRepaintBoundary(),
              ),
              Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}
