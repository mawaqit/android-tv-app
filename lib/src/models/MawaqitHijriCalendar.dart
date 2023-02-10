import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:mawaqit/generated/l10n.dart';
import 'package:mawaqit/src/helpers/StringUtils.dart';

class MawaqitHijriCalendar extends HijriCalendar {
  MawaqitHijriCalendar.fromDate(DateTime now) : super.fromDate(now);

  /// +1 is the difference between the Backend calculation and the frontend calculation
  factory MawaqitHijriCalendar.fromDateWithAdjustments(
    DateTime date, {
    int adjustment = 0,
    bool force30Days = false,
  }) {
    var hijri = MawaqitHijriCalendar.fromDate(
      date.add(Duration(days: adjustment + 1)),
    );

    if (force30Days) hijri.hDay = 30;

    return hijri;
  }

  String formatMawaqitType() {
    return [
      if (wkDay != null) '${DateFormat('EEEE').format(DateTime.now())},',
      hDay.toString(),
      '${monthName(hMonth - 1)},',
      hYear.toString(),
    ].join(' ').capitalizeFirstOfEach();
  }

  bool get isInLunarDays {
    return [13, 14, 15].contains(hDay);
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
