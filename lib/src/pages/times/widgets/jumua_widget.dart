import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/AppDate.dart';
import 'package:mawaqit/src/pages/home/widgets/FadeInOut.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/SalahItem.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart' show kDebugMode;

class JumuaWidget extends StatelessWidget {
  const JumuaWidget({super.key});
  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.watch<MosqueManager>();
    final userPrefs = context.watch<UserPreferencesManager>();

    if (mosqueManager.showEid(userPrefs.hijriAdjustments)) {
      return FadeInOutWidget(
        first: eidWidget(mosqueManager, context),
        duration: Duration(seconds: 30),
        second: jumuaTile(mosqueManager, context),
        secondDuration: Duration(seconds: 10),
        disableSecond: !AppDateTime.isFriday,
      );
    }

    return jumuaTile(mosqueManager, context);
  }

  Widget eidWidget(MosqueManager mosqueManager, BuildContext context) {
    return SalahItemWidget(
      active: true,
      withDivider: true,
      removeBackground: true,
      title: S.of(context).salatElEid,
      iqama: mosqueManager.times!.aidPrayerTime2,
      time: mosqueManager.times!.aidPrayerTime ?? "",
      isIqamaMoreImportant: false,
    );
  }

  Widget jumuaTile(MosqueManager mosqueManager, BuildContext context) {
    final jumuaTimes = mosqueManager.getOrderedJumuaTimes();

    // Add detailed logs for debugging
    final now = mosqueManager.mosqueDate();
    final isFriday = now.weekday == DateTime.friday;
    final nextIqamaIdx = mosqueManager.nextIqamaIndex();
    final isJumuaTime = mosqueManager.jumuaaWorkflowTime();

    // FORCE ACTIVE: Always highlight Juma on Fridays
    final forceActive = isFriday;

    // Original condition
    final shouldBeActive = isFriday && (nextIqamaIdx == 1 || isJumuaTime);

    // Use the forced active state
    final finalActiveState = forceActive;

    if (jumuaTimes.isEmpty) {
      developer.log('JUMUA_DEBUG: No Jumua times available');
      return SalahItemWidget(
        withDivider: true,
        removeBackground: true,
        title: S.of(context).jumua,
        time: "",
        isIqamaMoreImportant: false,
      );
    }

    return SalahItemWidget(
      withDivider: true,
      removeBackground: true,
      title: S.of(context).jumua,
      time: jumuaTimes[0],
      iqama: jumuaTimes.length > 1 ? jumuaTimes[1] : null,
      iqama2: jumuaTimes.length > 2 ? jumuaTimes[2] : null,
      isIqamaMoreImportant: false,
      active: finalActiveState,
    );
  }
}
