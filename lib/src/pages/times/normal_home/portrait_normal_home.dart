import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/pages/home/widgets/footer.dart';
import 'package:mawaqit/src/pages/home/widgets/mosque_header.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/SalahItem.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/horizontal_salah_item.dart';
import 'package:provider/provider.dart';

import '../../../../i18n/l10n.dart';
import '../../../helpers/AppDate.dart';
import '../../../services/mosque_manager.dart';
import '../../home/widgets/TimeWidget.dart';
import '../widgets/jumua_widget.dart';

class PortraitNormalHome extends StatelessWidget {
  const PortraitNormalHome({super.key});

  String salahName(int index) {
    switch (index) {
      case 0:
        return S.current.fajr;
      case 1:
        return S.current.duhr;
      case 2:
        return S.current.asr;
      case 3:
        return S.current.maghrib;
      case 4:
        return S.current.isha;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.watch<MosqueManager>();
    final today = mosqueManager.useTomorrowTimes ? AppDateTime.tomorrow() : AppDateTime.now();

    final times = mosqueManager.times!.dayTimesStrings(today);
    final iqamas = mosqueManager.times!.dayIqamaStrings(today);

    final isIqamaMoreImportant = mosqueManager.mosqueConfig!.iqamaMoreImportant == true;
    final iqamaEnabled = mosqueManager.mosqueConfig?.iqamaEnabled == true;

    final nextActiveSalah = mosqueManager.nextSalahIndex();

    return Column(
      children: [
        SizedBox(height: 15.vh, child: MosqueHeader(mosque: mosqueManager.mosque!)),
        FractionallySizedBox(widthFactor: .7, child: HomeTimeWidget().animate().slideY(begin: -1).fade()),
        SizedBox(height: 2.vh),
        Expanded(
          flex: 5,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.vw),
            child: Column(
              children: [
                for (var i = 0; i < 5; i++)
                  HorizontalSalahItem(
                    title: salahName(i),
                    time: times[i],
                    isIqamaMoreImportant: isIqamaMoreImportant,

                    /// disable duhr highlight on friday
                    active: nextActiveSalah == i && (i != 1 || !AppDateTime.isFriday || mosqueManager.times?.jumua == null),
                    iqama: iqamas[i],
                    showIqama: iqamaEnabled,
                    removeBackground: true,
                    withDivider: false,
                  ),
              ]
                  .mapIndexed(
                      (i, e) => Expanded(child: e.animate(delay: Duration(milliseconds: 100 * i)).slideX(begin: 1).fadeIn()))
                  .toList(),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Expanded(
                  child: Center(
                      child: SalahItemWidget(
                title: S.of(context).shuruk,
                time: mosqueManager.getShurukTimeString() ?? '',
                removeBackground: true,
              ).animate().slideX(begin: -1).fadeIn())),
              Expanded(
                child: Center(
                  child: JumuaWidget().animate().slideX(begin: 1).fadeIn(),
                ),
              ),
            ],
          ),
        ),
        Footer().animate().slideY(begin: 1).fadeIn(),
      ],
    );
  }
}
