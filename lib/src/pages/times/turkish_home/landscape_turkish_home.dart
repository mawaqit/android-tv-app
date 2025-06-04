import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
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

import '../../../../i18n/AppLanguage.dart';
import '../../../../main.dart';
import '../../../state_management/app_update/app_update_notifier.dart';
import '../../../state_management/app_update/app_update_state.dart';
import '../../../widgets/show_update_alert.dart';

class LandScapeTurkishHome extends riverpod.ConsumerStatefulWidget {
  const LandScapeTurkishHome({super.key});

  @override
  riverpod.ConsumerState createState() => _LandScapeTurkishHomeState();
}

class _LandScapeTurkishHomeState extends riverpod.ConsumerState<LandScapeTurkishHome> {
  String salahName(int index) {
    switch (index) {
      case 0:
        return S.current.sabah;
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

  late Timer _updateTimer;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mosque = Provider.of<MosqueManager>(context, listen: false);
      ref.read(appUpdateProvider.notifier).startUpdateScheduler(
            mosque,
            context.read<AppLanguage>().appLocal.languageCode,
            context,
          );
    });
    super.initState();
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(appUpdateProvider, (previous, next) {
      if (next.hasValue && !next.isReloading && next.value!.appUpdateStatus == AppUpdateStatus.updateAvailable) {
        showUpdateAlert(
          context: context,
          onDismissPressed: () => ref.read(appUpdateProvider.notifier).dismissUpdate(),
          duration: Duration(minutes: 5),
          content: next.value!.releaseNote,
          title: next.value!.message,
          onPressed: () => ref.read(appUpdateProvider.notifier).openStore(),
        );
      }
    });
    final mosqueManager = context.watch<MosqueManager>();
    final today = mosqueManager.useTomorrowTimes ? AppDateTime.tomorrow() : AppDateTime.now();

    final times = mosqueManager.times!.dayTimesStrings(today, salahOnly: false);
    final iqamas = mosqueManager.times!.dayIqamaStrings(today);

    final isIqamaMoreImportant = mosqueManager.mosqueConfig!.iqamaMoreImportant == true;
    final iqamaEnabled = mosqueManager.mosqueConfig?.iqamaEnabled == true;

    final nextActiveSalah = mosqueManager.mosqueConfig!.iqamaMoreImportant == true
        ? mosqueManager.nextSalahAfterIqamaIndex()
        : mosqueManager.nextSalahIndex();
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
                  child: SalahItemWidget(
                    title: S.of(context).sabah,
                    time: times[1],
                    removeBackground: true,
                    showIqama: iqamaEnabled,
                    withDivider: true,
                    isIqamaMoreImportant: isIqamaMoreImportant,
                    active: nextActiveSalah == 0,
                    iqama: iqamas[0],
                  ).animate().slideX().fade(),
                ),
              ),
              Expanded(flex: 4, child: HomeTimeWidget().animate().slideY().fade()),
              Expanded(flex: 2, child: Center(child: JumuaWidget().animate().slideX(begin: 1).fade())),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.vw),
            child: Row(
              children: [
                /// imsak tile
                SalahItemWidget(
                  title: S.of(context).imsak,
                  time: times[0],
                  withDivider: false,
                  iqama: '',
                  showIqama: iqamaEnabled,
                  isIqamaMoreImportant: isIqamaMoreImportant,
                ),

                /// shuruk tile
                SalahItemWidget(
                  title: S.of(context).shuruk,
                  time: times[2],
                  withDivider: false,
                  iqama: '',
                  showIqama: iqamaEnabled,
                  isIqamaMoreImportant: isIqamaMoreImportant,
                ),

                /// duhr tile
                SalahItemWidget(
                  title: salahName(1),
                  time: times[3],
                  isIqamaMoreImportant: isIqamaMoreImportant,
                  active: nextActiveSalah == 1 && (!AppDateTime.isFriday || mosqueManager.times?.jumua == null),
                  iqama: iqamas[1],
                  showIqama: iqamaEnabled,
                  withDivider: false,
                ),
                for (var i = 2; i < 5; i++)
                  SalahItemWidget(
                    title: salahName(i),
                    time: times[i + 2],
                    isIqamaMoreImportant: isIqamaMoreImportant,
                    active: nextActiveSalah == i,
                    iqama: iqamas[i],
                    showIqama: iqamaEnabled,
                    withDivider: false,
                  ),
              ]
                  .mapIndexed((i, e) => Expanded(
                          child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 1.vw),
                        child: e.animate(delay: Duration(milliseconds: 100 * i)).slideY(begin: 1).fade(),
                      )))
                  .toList(),
            ),
          ),
        ),
        Footer().animate().slideY(begin: 1).fade(),
      ],
    );
  }
}
