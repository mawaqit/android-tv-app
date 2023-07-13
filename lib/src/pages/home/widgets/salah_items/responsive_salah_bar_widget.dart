import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/repaint_boundaries.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/SalahItem.dart';
import 'package:mawaqit/src/pages/home/widgets/orientation_widget.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/horizontal_salah_item.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

/// salah item animation step duration
const _step = Duration(milliseconds: 100);

/// salah item animation duration
const _duration = Duration(milliseconds: 300);

class ResponsiveSalahBarWidget extends StatelessOrientationWidget {
  const ResponsiveSalahBarWidget({super.key, this.activeItem});

  final int? activeItem;

  @override
  Widget buildLandscape(BuildContext context) {
    final mosqueProvider = context.watch<MosqueManager>();
    final nextActiveIqama = activeItem ?? mosqueProvider.nextIqamaIndex();

    final todayTimes = mosqueProvider.salahBarTimes();
    final todayIqama = mosqueProvider.useTomorrowTimes ? mosqueProvider.tomorrowIqama : mosqueProvider.todayIqama;

    /// on jumuaa we disable duhr highlight for mosques only
    bool duhrHighlightDisable = mosqueProvider.mosqueDate().weekday == DateTime.friday && mosqueProvider.typeIsMosque;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.vw),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < 5; i++)
            SalahItemWidget(
              title: mosqueProvider.salahName(i),
              time: todayTimes[i],
              iqama: todayIqama[i],
              active: i == 1 ? nextActiveIqama == i && !duhrHighlightDisable : nextActiveIqama == i,
              withDivider: false,
              showIqama: mosqueProvider.mosqueConfig?.iqamaEnabled == true,
              isIqamaMoreImportant: mosqueProvider.mosqueConfig?.iqamaMoreImportant ?? false,
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
    final todayIqama = mosqueProvider.useTomorrowTimes ? mosqueProvider.tomorrowIqama : mosqueProvider.todayIqama;

    /// on jumuaa we disable duhr highlight for mosques only
    bool duhrHighlightDisable = mosqueProvider.mosqueDate().weekday == DateTime.friday && mosqueProvider.typeIsMosque;

    return Column(
      children: [
        SizedBox(height: 2.vh ),
        for (var i = 0; i < 5; i++)
          HorizontalSalahItem(
            title: mosqueProvider.salahName(i),
            time: todayTimes[i],
            iqama: todayIqama[i],
            active: i == 1 ? nextActiveIqama == i && !duhrHighlightDisable : nextActiveIqama == i,
            withDivider: false,
            removeBackground: true,
            showIqama: mosqueProvider.mosqueConfig?.iqamaEnabled == true,
            isIqamaMoreImportant: mosqueProvider.mosqueConfig?.iqamaMoreImportant ?? false,
          )
              .animate(delay: _step * i)
              .fadeIn(duration: _duration)
              .slideX(begin: 1, duration: _duration, curve: Curves.easeOut)
              .addRepaintBoundary(),
      ],
    );
  }
}
