import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../i18n/l10n.dart';
import '../../../services/mosque_manager.dart';
import 'SalahItem.dart';

/// this widget is responsible for showing the
/// (shuruk time, jumuaa time, or eid time)
class ShurukWidget extends StatelessWidget {
  const ShurukWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mosqueProvider = context.read<MosqueManager>();

    if (mosqueProvider.showEid) {
      return SalahItemWidget(
        title: S.of(context).salatElEid,
        iqama: mosqueProvider.times!.aidPrayerTime2,
        time: mosqueProvider.times!.aidPrayerTime ?? "",
        removeBackground: false,
        withDivider: mosqueProvider.times!.aidPrayerTime2 != null,
        active: true,
      );
    }

    if (!mosqueProvider.isShurukTime && mosqueProvider.isImsakEnabled) {
      return SalahItemWidget(
        title: S.of(context).imsak,
        time: mosqueProvider.imsak,
        removeBackground: true,
        isIqamaMoreImportant: mosqueProvider.mosqueConfig?.iqamaMoreImportant ?? false,
      );
    }

    return SalahItemWidget(
      title: S.of(context).shuruk,
      time: mosqueProvider.times!.shuruq ?? "",
      removeBackground: true,
      isIqamaMoreImportant: mosqueProvider.mosqueConfig?.iqamaMoreImportant ?? false,
    );
  }
}
