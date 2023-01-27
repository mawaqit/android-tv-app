import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../generated/l10n.dart';
import '../../../services/mosque_manager.dart';
import 'SalahItem.dart';

class ShurukWidget extends StatelessWidget {
  const ShurukWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mosqueProvider = context.read<MosqueManager>();

    return mosqueProvider.showImsak
        ? Center(
            child: SalahItemWidget(
              title: S.of(context).imsak,
              time: mosqueProvider.imsak,
              removeBackground: true,
              withDivider: false,
            ),
          )
        : mosqueProvider.showEid
            ? Center(
                child: SalahItemWidget(
                  title: "Salat El Eid",
                  iqama: mosqueProvider.times!.aidPrayerTime2,
                  time: mosqueProvider.times!.aidPrayerTime ?? "",
                  removeBackground: false,
                  withDivider: mosqueProvider.times!.aidPrayerTime2 != null,
                  active: true,
                ),
              )
            : Center(
                child: SalahItemWidget(
                  title: S.of(context).shuruk,
                  time: mosqueProvider.times!.shuruq ?? "",
                  removeBackground: true,
                  withDivider: false,
                  active: mosqueProvider.activateShroukItem,
                ),
              );
  }
}
