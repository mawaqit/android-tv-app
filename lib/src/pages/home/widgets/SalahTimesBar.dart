import 'package:flutter/material.dart';
import 'package:mawaqit/generated/l10n.dart';
import 'package:mawaqit/src/pages/home/widgets/SalahItem.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

/// the bottom bar of 5 salah times
class SalahTimesBar extends StatelessWidget {
  const SalahTimesBar({Key? key, this.miniStyle = false}) : super(key: key);

  final bool miniStyle;

  @override
  Widget build(BuildContext context) {
    final mosqueProvider = context.watch<MosqueManager>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SalahItemWidget(
          title: miniStyle ? null : S.of(context).fajr,
          time: mosqueProvider.todayTimes[0],
          iqama: miniStyle?null:mosqueProvider.todayIqama[0],
          active: mosqueProvider.nextSalahIndex() == 1,
          withDivider: false,
        ),
        SalahItemWidget(
          title: miniStyle ? null : S.of(context).duhr,
          time: mosqueProvider.todayTimes[1],
          iqama: miniStyle?null:mosqueProvider.todayIqama[1],
          active: mosqueProvider.nextSalahIndex() == 2,
          withDivider: false,
        ),
        SalahItemWidget(
          title: miniStyle ? null : S.of(context).asr,
          time: mosqueProvider.todayTimes[2],
          iqama:miniStyle?null: mosqueProvider.todayIqama[2],
          active: mosqueProvider.nextSalahIndex() == 3,
          withDivider: false,
        ),
        SalahItemWidget(
          title: miniStyle ? null : S.of(context).maghrib,
          time: mosqueProvider.todayTimes[3],
          iqama:miniStyle?null: mosqueProvider.todayIqama[3],
          active: mosqueProvider.nextSalahIndex() == 4,
          withDivider: false,
        ),
        SalahItemWidget(
          title: miniStyle ? null : S.of(context).isha,
          time: mosqueProvider.todayTimes[4],
          iqama:miniStyle?null: mosqueProvider.todayIqama[4],
          active: mosqueProvider.nextSalahIndex() == 0,
          withDivider: false,
        ),
      ],
    );
  }
}
