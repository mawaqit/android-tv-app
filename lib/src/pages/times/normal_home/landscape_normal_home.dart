import 'dart:developer';

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
import '../../home/widgets/FadeInOut.dart';

class LandscapeNormalHome extends riverpod.ConsumerStatefulWidget {
  const LandscapeNormalHome({super.key});

  @override
  riverpod.ConsumerState createState() => _LandscapeNormalHomeState();
}

class _LandscapeNormalHomeState extends riverpod.ConsumerState<LandscapeNormalHome> {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(appUpdateProvider, (previous, next) {
      if (next.hasValue && !next.isReloading && next.value!.appUpdateStatus == AppUpdateStatus.updateAvailable) {
        log('update available ${next.value} || ${next.isReloading} || ${next.isLoading} || ${next.hasValue}');
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
                      isIqamaMoreImportant: mosqueManager.mosqueConfig!.iqamaMoreImportant == true,
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
              Expanded(child: HomeTimeWidget().animate().fadeIn().slideY(begin: -1), flex: 4),
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
                        child: e.animate(delay: Duration(milliseconds: 100 * i)).slideY(begin: 1).fadeIn(),
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
