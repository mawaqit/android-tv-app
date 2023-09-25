import 'package:flutter/material.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:provider/provider.dart';

import '../../../../i18n/l10n.dart';
import '../../../services/mosque_manager.dart';
import 'salah_items/SalahItem.dart';

/// this widget is responsible for showing the
/// (shuruk time, jumuaa time, or eid time)
class ShurukWidget extends StatelessWidget {
  const ShurukWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mosqueProvider = context.read<MosqueManager>();
    final userPrefs = context.read<UserPreferencesManager>();

    if (mosqueProvider.showEid(userPrefs.hijriAdjustments)) {
      return SalahItemWidget(
        title: S.of(context).salatElEid,
        iqama: mosqueProvider.times!.aidPrayerTime2,
        time: mosqueProvider.times!.aidPrayerTime ?? "",
        removeBackground: false,
        withDivider: mosqueProvider.times!.aidPrayerTime2 != null,
        active: true,
      );
    }

    if (!mosqueProvider.isShurukTime && mosqueProvider.isImsakEnabled && !mosqueProvider.times!.isTurki) {
      return SalahItemWidget(
        title: S.of(context).imsak,
        time: mosqueProvider.imsak,
        removeBackground: true,
      );
    }

    return SalahItemWidget(
      title: S.of(context).shuruk,
      time: mosqueProvider.getShurukTimeString() ?? "",
      removeBackground: true,
    );
  }
}
