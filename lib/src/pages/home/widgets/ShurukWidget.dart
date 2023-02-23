import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../i18n/l10n.dart';
import '../../../services/mosque_manager.dart';
import 'SalahItem.dart';

class ShurukWidget extends StatelessWidget {
  const ShurukWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mosqueProvider = context.read<MosqueManager>();

    if (mosqueProvider.showEid) {
      return SalahItemWidget(
        title: "Salat El Eid",
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
      );
    }

    return SalahItemWidget(
      title: S.of(context).shuruk,
      time: mosqueProvider.times!.shuruq ?? "",
      removeBackground: true,
    );
  }
}
