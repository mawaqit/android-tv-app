import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/AppDate.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/extensions/iterator.dart';
import 'package:mawaqit/src/helpers/repaint_boundaries.dart';
import 'package:mawaqit/src/pages/home/widgets/orientation_widget.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/SalahItem.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/horizontal_salah_item.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

/// salah item animation step duration
const _step = Duration(milliseconds: 150);

/// salah item animation duration
const _duration = Duration(milliseconds: 300);

class ResponsiveSalahBarWidget extends StatelessOrientationWidget {
  const ResponsiveSalahBarWidget({super.key, this.activeItem});

  final int? activeItem;

  @override
  Widget buildLandscape(BuildContext context) {
    final mosqueProvider = context.watch<MosqueManager>();
    final nextActiveIqama = activeItem ?? mosqueProvider.nextIqamaIndex();
    final times = mosqueProvider.times!;
    final todayTimes = mosqueProvider.useTomorrowTimes
        ? times.dayTimesStrings(AppDateTime.now().add(1.days), salahOnly: false)
        : times.dayTimesStrings(AppDateTime.now(), salahOnly: false);
    final todayIqama = mosqueProvider.useTomorrowTimes ? mosqueProvider.tomorrowIqama : mosqueProvider.todayIqama;

    /// on jumuaa we disable duhr highlight for mosques only
    bool duhrHighlightDisable = AppDateTime.isFriday && mosqueProvider.typeIsMosque;

    final imsakForTurkish = times.isTurki ? todayTimes.removeAt(0) : null;
    // remove the imsak time
    todayTimes.removeAt(1);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.vw),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (imsakForTurkish != null)
              Expanded(
                child: SalahItemWidget(
                  time: imsakForTurkish,
                  title: S.of(context).imsak,
                )
                    .animate()
                    .fadeIn(duration: _duration)
                    .slideY(begin: 1, duration: _duration, curve: Curves.easeOut)
                    .addRepaintBoundary(),
              ),
            for (var i = 0; i < 5; i++)
              Expanded(
                child: SalahItemWidget(
                  title: mosqueProvider.salahName(i),
                  time: todayTimes[i],
                  iqama: todayIqama[i],
                  active: i == 1 ? nextActiveIqama == i && !duhrHighlightDisable : nextActiveIqama == i,
                  withDivider: false,
                  showIqama: mosqueProvider.mosqueConfig?.iqamaEnabled == true,
                  isIqamaMoreImportant: mosqueProvider.mosqueConfig?.iqamaMoreImportant ?? false,
                )
                    .animate(delay: _step * (i + 1))
                    .fadeIn(duration: _duration)
                    .slideY(begin: 1, duration: _duration, curve: Curves.easeOut)
                    .addRepaintBoundary(),
              ),
          ].addPadding(width: 1.vw),
        ),
      ),
    );
  }

  @override
  Widget buildPortrait(BuildContext context) {
    final mosqueProvider = context.watch<MosqueManager>();
    final nextActiveIqama = activeItem ?? mosqueProvider.nextIqamaIndex();

    final times = mosqueProvider.times!;
    final todayTimes = mosqueProvider.useTomorrowTimes
        ? times.dayTimesStrings(AppDateTime.now().add(1.days), salahOnly: false)
        : times.dayTimesStrings(AppDateTime.now(), salahOnly: false);
    final todayIqama = mosqueProvider.useTomorrowTimes ? mosqueProvider.tomorrowIqama : mosqueProvider.todayIqama;

    /// on jumuaa we disable duhr highlight for mosques only
    bool duhrHighlightDisable = mosqueProvider.mosqueDate().weekday == DateTime.friday && mosqueProvider.typeIsMosque;

    final imsakForTurkish = times.isTurki ? todayTimes.removeAt(0) : null;

    /// remove the shuruq time from the list
    todayTimes.removeAt(1);

    return Column(
      children: [
        if (imsakForTurkish != null)
          Expanded(
            child: HorizontalSalahItem(
              time: imsakForTurkish,
              title: S.of(context).imsak,
              iqama: '',
              removeBackground: true,
            ),
          ),
        for (var i = 0; i < 5; i++)
          Expanded(
            child: HorizontalSalahItem(
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
          ),
      ],
    );
  }
}
