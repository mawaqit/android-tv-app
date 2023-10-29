import 'package:flutter/widgets.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/AppDate.dart';
import 'package:mawaqit/src/pages/home/widgets/FadeInOut.dart';
import 'package:mawaqit/src/pages/home/widgets/salah_items/SalahItem.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:provider/provider.dart';

class JumuaWidget extends StatelessWidget {
  const JumuaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.watch<MosqueManager>();
    final userPrefs = context.watch<UserPreferencesManager>();

    /// show eid instead of jumuaa if its eid time and eid is enabled
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
      isIqamaMoreImportant: mosqueManager.mosqueConfig!.iqamaMoreImportant == true,
    );
  }

  Widget jumuaTile(MosqueManager mosqueManager, BuildContext context) {
    return SalahItemWidget(
      withDivider: true,
      removeBackground: true,
      title: S.of(context).jumua,
      time: mosqueManager.jumuaTime ?? "",
      iqama: mosqueManager.times!.jumua2,
      isIqamaMoreImportant: mosqueManager.mosqueConfig!.iqamaMoreImportant == true,
      active: mosqueManager.nextIqamaIndex() == 1 && AppDateTime.isFriday && mosqueManager.times?.jumua != null,
    );
  }
}
