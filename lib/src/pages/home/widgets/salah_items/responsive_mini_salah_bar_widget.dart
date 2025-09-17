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
  const ResponsiveMiniSalahBarWidget({
    super.key,
    this.activeItem,
    this.horizontalPadding,
    this.itemSpacing,
    this.useCompactLayout = false,
  });

  /// used to force salah item to be active
  /// if null, will be calculated based on next iqama
  final int? activeItem;

  /// Custom horizontal padding for the entire bar
  final double? horizontalPadding;

  /// Custom spacing between items (portrait mode)
  final double? itemSpacing;

  /// Use compact layout with reduced spacing
  final bool useCompactLayout;

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
    final isIqamaMoreImportant = mosqueProvider.mosqueConfig!.iqamaMoreImportant == true;

    /// on jumuaa we disable duhr highlight for mosques only
    bool duhrHighlightDisable = mosqueProvider.mosqueDate().weekday == DateTime.friday && mosqueProvider.typeIsMosque;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding ?? (useCompactLayout ? 1.5.vw : 3.vw)),
      child: Row(
        mainAxisAlignment: useCompactLayout ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.spaceBetween,
        children: [
          if (turkishImask != null)
            Flexible(
              child: SalahItemWidget(
                      removeBackground: true, time: turkishImask, isIqamaMoreImportant: isIqamaMoreImportant)
                  .animate()
                  .fadeIn(duration: _duration)
                  .slideY(begin: 1, duration: _duration, curve: Curves.easeOut)
                  .addRepaintBoundary(),
            ),
          for (var i = 0; i < 5; i++)
            Flexible(
              child: SalahItemWidget(
                      withDivider: false,
                      iqama: isIqamaMoreImportant ? iqamas[i] : null,
                      time: todayTimes[i],
                      active: i == 1 ? nextActiveIqama == i && !duhrHighlightDisable : nextActiveIqama == i,
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
    final isIqamaMoreImportant = mosqueProvider.mosqueConfig!.iqamaMoreImportant == true;
    final turkishImask = todayTimes.length == 7 ? todayTimes.removeAt(0) : null;
    todayTimes.removeAt(1);

    // Helper function to generate SalahItemWidget
    Widget buildSalahItemWidget({
      required String title,
      required String time,
      required String iqama,
      required bool active,
    }) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 1.vw),
        child: SizedBox(
          width: 22.vw,
          height: 12.vh,
          child: SalahItemWidget(
            title: title,
            time: time,
            iqama: isIqamaMoreImportant ? iqama : null,
            active: active,
            isIqamaMoreImportant: isIqamaMoreImportant,
          )
              .animate()
              .fadeIn(duration: _duration)
              .slideY(begin: 1, duration: _duration, curve: Curves.easeOut)
              .addRepaintBoundary(),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding ?? (useCompactLayout ? 0.5.vw : 1.vw)),
      child: Wrap(
        spacing: itemSpacing ?? (useCompactLayout ? 1.vw : 2.vw),
        runSpacing: 2.vh,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (turkishImask != null)
                buildSalahItemWidget(
                  title: S.of(context).imsak,
                  time: todayTimes[0],
                  iqama: iqamas[0],
                  active: nextActiveIqama == 0,
                ),
              for (int index = 0; index < (turkishImask != null ? 2 : 3); index++)
                buildSalahItemWidget(
                  title: mosqueProvider.salahName(index),
                  time: todayTimes[index],
                  iqama: iqamas[index],
                  active: index == 1 ? nextActiveIqama == index : nextActiveIqama == index,
                ),
            ],
          ),
          if (turkishImask != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => buildSalahItemWidget(
                  title: mosqueProvider.salahName(index + 2),
                  time: todayTimes[index + 2],
                  iqama: iqamas[index + 2],
                  active: (index + 2) == 1 ? nextActiveIqama == (index + 2) : nextActiveIqama == (index + 2),
                ),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                2,
                (index) => buildSalahItemWidget(
                  title: mosqueProvider.salahName(index + 3),
                  time: todayTimes[index + 3],
                  iqama: iqamas[index + 3],
                  active: (index + 3) == 1 ? nextActiveIqama == (index + 3) : nextActiveIqama == (index + 3),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
