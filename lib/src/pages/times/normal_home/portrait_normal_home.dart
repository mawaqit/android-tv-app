import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/pages/home/widgets/footer.dart';
import 'package:mawaqit/src/pages/home/widgets/mosque_header.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/SalahItem.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/horizontal_salah_item.dart';
import 'package:provider/provider.dart';

import '../../../../i18n/AppLanguage.dart';
import '../../../../i18n/l10n.dart';
import '../../../../main.dart';
import '../../../helpers/AppDate.dart';
import '../../../services/mosque_manager.dart';
import '../../../state_management/app_update/app_update_notifier.dart';
import '../../../state_management/app_update/app_update_state.dart';
import '../../../widgets/show_update_alert.dart';
import '../../home/widgets/FadeInOut.dart';
import '../../home/widgets/TimeWidget.dart';
import '../widgets/jumua_widget.dart';

class PortraitNormalHome extends riverpod.ConsumerStatefulWidget {
  const PortraitNormalHome({super.key});

  @override
  riverpod.ConsumerState<PortraitNormalHome> createState() => _PortraitNormalHomeState();
}

class _PortraitNormalHomeState extends riverpod.ConsumerState<PortraitNormalHome> {
  String salahName(int index, BuildContext context) {
    switch (index) {
      case 0:
        return S.of(context).fajr;
      case 1:
        return S.of(context).duhr;
      case 2:
        return S.of(context).asr;
      case 3:
        return S.of(context).maghrib;
      case 4:
        return S.of(context).isha;
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
          duration: Duration(minutes: 5),
          content: next.value!.releaseNote,
          title: next.value!.message,
          onPressed: () => ref.read(appUpdateProvider.notifier).openStore(),
          onDismissPressed: () => ref.read(appUpdateProvider.notifier).dismissUpdate(),
        );
      }
    });

    final mosqueManager = context.watch<MosqueManager>();
    final today = mosqueManager.useTomorrowTimes ? AppDateTime.tomorrow() : AppDateTime.now();

    final times = mosqueManager.times!.dayTimesStrings(today);
    final iqamas = mosqueManager.times!.dayIqamaStrings(today);

    final isIqamaMoreImportant = mosqueManager.mosqueConfig!.iqamaMoreImportant == true;
    final iqamaEnabled = mosqueManager.mosqueConfig?.iqamaEnabled == true;

    final nextActiveSalah = mosqueManager.mosqueConfig!.iqamaMoreImportant == true
        ? mosqueManager.nextSalahAfterIqamaIndex()
        : mosqueManager.nextSalahIndex();
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
                    title: salahName(i, context),
                    time: times[i],
                    isIqamaMoreImportant: isIqamaMoreImportant,

                    /// disable duhr highlight on friday
                    active:
                        nextActiveSalah == i && (i != 1 || !AppDateTime.isFriday || mosqueManager.times?.jumua == null),
                    iqama: iqamas[i],
                    showIqama: iqamaEnabled,
                    removeBackground: true,
                    withDivider: false,
                  ),
              ]
                  .mapIndexed((i, e) =>
                      Expanded(child: e.animate(delay: Duration(milliseconds: 100 * i)).slideX(begin: 1).fadeIn()))
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
                child: FadeInOutWidget(
                  duration: Duration(seconds: 15),
                  disableSecond: mosqueManager.isImsakEnabled == false,
                  first: SalahItemWidget(
                    removeBackground: true,
                    title: S.of(context).shuruk,
                    time: mosqueManager.getShurukTimeString() ?? '',
                    isIqamaMoreImportant: mosqueManager.mosqueConfig!.iqamaMoreImportant == true,
                  ),
                  secondDuration: Duration(seconds: 15),
                  second: SalahItemWidget(
                    title: S.of(context).imsak,
                    time: mosqueManager.imsak ?? "",
                    removeBackground: true,
                  ),
                ),
              )),
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
