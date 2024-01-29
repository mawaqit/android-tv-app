import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/AppDate.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/pages/home/widgets/TimeWidget.dart';
import 'package:mawaqit/src/pages/home/widgets/footer.dart';
import 'package:mawaqit/src/pages/home/widgets/mosque_header.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/SalahItem.dart';
import 'package:mawaqit/src/pages/times/widgets/jumua_widget.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

import '../../home/widgets/FadeInOut.dart';

class LandscapeNormalHome extends StatelessWidget {
  const LandscapeNormalHome({super.key});

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
    final today = mosqueManager.useTomorrowTimes
        ? AppDateTime.tomorrow()
        : AppDateTime.now();

    final times = mosqueManager.times!.dayTimesStrings(today);
    final iqamas = mosqueManager.times!.dayIqamaStrings(today);

    final isIqamaMoreImportant =
        mosqueManager.mosqueConfig!.iqamaMoreImportant == true;
    final iqamaEnabled = mosqueManager.mosqueConfig?.iqamaEnabled == true;

    final nextActiveSalah = mosqueManager.nextSalahIndex();

    return Column(
      children: [
        MosqueHeader(mosque: mosqueManager.mosque!),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Center(
                  child: FadeInOutWidget(
                    duration: Duration(seconds: 15),
                    disableSecond: mosqueManager.isImsakEnabled == false,
                    first: SalahItemWidget(
                      removeBackground: true,
                      title: S.of(context).shuruk,
                      time: mosqueManager.getShurukTimeString() ?? '',
                      isIqamaMoreImportant:
                          mosqueManager.mosqueConfig!.iqamaMoreImportant ==
                              true,
                    ),
                    secondDuration: Duration(seconds: 15),
                    second: SalahItemWidget(
                      title: S.of(context).imsak,
                      time: mosqueManager.imsak ?? "",
                      removeBackground: true,
                    ),
                  ),
                ),
              ),
              Expanded(


                  child: HomeTimeWidget().animate().fadeIn().slideY(begin: -1), flex: 4),
              Expanded(
                flex: 2,
                child:
                    Center(child: JumuaWidget().animate(delay: Duration(milliseconds: 500)).slideX(begin: 1).fadeIn()),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.vw),
            child: Row(
              children: [
                for (var i = 0; i < 5; i++)
                  SalahItemWidget(
                    title: salahName(i),
                    time: times[i],
                    iqama: iqamas[i],
                    withDivider: false,
                    showIqama: iqamaEnabled,
                    active:
                        nextActiveSalah == i && (i != 1 || !AppDateTime.isFriday || mosqueManager.times?.jumua == null),
                    isIqamaMoreImportant: isIqamaMoreImportant,
                  ),
              ]
                  .mapIndexed((i, e) => Expanded(
                          child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 1.vw),
                        child: e
                            .animate(delay: Duration(milliseconds: 100 * i))
                            .slideY(begin: 1)
                            .fadeIn(),
                      )))
                  .toList(),
            ),
          ),
        ),
        Footer().animate().fade().slideY(begin: 1),
      ],
    );
  }
}
