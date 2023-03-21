import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/repaint_boundaries.dart';
import 'package:mawaqit/src/pages/home/widgets/SalahItem.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

/// the bottom bar of 5 salah times
class SalahTimesBar extends StatelessWidget {
  const SalahTimesBar({
    Key? key,
    this.miniStyle = false,
    this.microStyle = false,
    this.activeItem,
  }) : super(key: key);

  /// if true will hide salah name
  final bool miniStyle;

  /// if true will hide iqama time
  final bool microStyle;

  /// force to highlight salah item
  final int? activeItem;

  @override
  Widget build(BuildContext context) {
    final mosqueProvider = context.watch<MosqueManager>();

    final nextActiveIqama = activeItem ?? mosqueProvider.nextIqamaIndex();

    final todayTimes = mosqueProvider.salahBarTimes();

    final todayIqama = mosqueProvider.useTomorrowTimes ? mosqueProvider.tomorrowIqama : mosqueProvider.todayIqama;

    final step = Duration(milliseconds: 100);
    final duration = Duration(milliseconds: 300);

    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 3.vw),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < 5; i++)
              SalahItemWidget(
                title: miniStyle ? null : mosqueProvider.salahName(i),
                time: todayTimes[i],
                iqama: microStyle ? null : todayIqama[i],
                active: nextActiveIqama == i,
                withDivider: false,
                showIqama: mosqueProvider.mosqueConfig?.iqamaEnabled == true,
              )
                  .animate(delay: step * i)
                  .fadeIn(duration: duration)
                  .slideY(begin: 1, duration: duration)
                  .addRepaintBoundary(),
          ],
        ),
      ),
    );
  }
}
