import 'package:flutter/material.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
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

    return Padding(
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
          ),
          SalahItemWidget(
            title: miniStyle ? null : tr.duhr,
            time: todayTimes[1],
            iqama: microStyle ? null : todayIqama[1],
            active: nextActiveIqama == 1,
            withDivider: false,
          ),
          SalahItemWidget(
            title: miniStyle ? null : tr.asr,
            time: todayTimes[2],
            iqama: microStyle ? null : todayIqama[2],
            active: nextActiveIqama == 2,
            withDivider: false,
          ),
          SalahItemWidget(
            title: miniStyle ? null : tr.maghrib,
            time: todayTimes[3],
            iqama: microStyle ? null : todayIqama[3],
            active: nextActiveIqama == 3,
            withDivider: false,
          ),
          SalahItemWidget(
            title: miniStyle ? null : tr.isha,
            time: todayTimes[4],
            iqama: microStyle ? null : todayIqama[4],
            active: nextActiveIqama == 4,
            withDivider: false,
          ),
        ],
      ),
    );
  }
}
