import 'package:intl/intl.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/helpers/StringUtils.dart';

import 'kuwaiti_calendar.dart';

class MawaqitHijriCalendar extends KuwaitiCalendar {
  MawaqitHijriCalendar.fromDate(DateTime now) : super.fromDatetime(now);

  /// +1 is the difference between the Backend calculation and the frontend calculation
  MawaqitHijriCalendar.fromDateWithAdjustments(
    DateTime date, {
    int adjustment = 0,
    bool force30Days = false,
  }) : super.fromDatetime(date, dayShift: adjustment, force30: force30Days);

  String formatMawaqitType() {
    final dayFormatter = DateFormat('EEEE', S.current.localeName);

    return [
      islamicDate.toString(),
      '${monthName(islamicMonth)},',
      islamicYear.toString(),
    ].join(' ').capitalizeFirstOfEach();
  }

  bool get isInLunarDays {
    return [13, 14, 15].contains(islamicDate);
  }

  String monthName(int month) {
    switch (month) {
      case 0:
        return S.current.muharram;
      case 1:
        return S.current.safar;
      case 2:
        return S.current.rabiAlawwal;
      case 3:
        return S.current.rabiAlthani;
      case 4:
        return S.current.jumadaAlula;
      case 5:
        return S.current.jumadaAlakhirah;
      case 6:
        return S.current.rajab;
      case 7:
        return S.current.shaban;
      case 8:
        return S.current.ramadan;
      case 9:
        return S.current.shawwal;
      case 10:
        return S.current.dhuAlqidah;
      case 11:
        return S.current.dhuAlhijjah;
      default:
        return '';
    }
  }
}
