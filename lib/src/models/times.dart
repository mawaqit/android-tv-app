import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/AppDate.dart';
import 'package:mawaqit/src/helpers/time_utils.dart';

class Times {
  final String? jumua;
  final String? jumua2;
  final String? aidPrayerTime;
  final String? aidPrayerTime2;
  final int hijriAdjustment;
  final bool hijriDateForceTo30;
  final bool jumuaAsDuhr;
  final int imsakNbMinBeforeFajr;
  // final String? shuruq;

  // final List<String> times;
  @protected
  final List calendar;

  @protected
  final List iqamaCalendar;

//<editor-fold desc="Data Methods">

  bool get isTurki => dayTimesStrings(AppDateTime.now(), salahOnly: false).length == 7;

  /// if [salahOnly] is true, it will return only the salah times, otherwise it will return all the times including Sabah(turki) and shuruq
  List<String> dayTimesStrings(DateTime date, {bool salahOnly = true}) {
    final dayTimes = List<String>.from(calendar[date.month - 1][date.day.toString()]);

    if (!salahOnly) return dayTimes;

    /// turki uses 7 times, so we remove the first one
    if (dayTimes.length == 7) {
      // remove fajr as its not used for adhan calculations
      dayTimes.removeAt(0);
    }

    // remove shuruq as its not used for adhan calculations
    dayTimes.removeAt(1);

    return dayTimes;
  }

  List<String> dayIqamaStrings(DateTime date) =>
      List.from(iqamaCalendar[date.month - 1][date.day.toString()]!.take(6))..remove(1);

  List<DateTime> dayTimes(DateTime date) => dayTimesStrings(date).map((e) => e.toTodayDate(date)).toList();

  List<DateTime> dayIqamas(DateTime date) {
    final times = dayTimes(date);
    return dayIqamaStrings(date).mapIndexed((i, e) => e.toTodayDate(date, times[i])).toList();
  }

  DateTime daySalahTime(DateTime date, int salahIndex) => dayTimesStrings(date)[salahIndex].toTodayDate(date);

  DateTime? dayIqamaTime(DateTime date, int salahIndex) => dayIqamaStrings(date)[salahIndex].toTodayDate(date);

  /// return the shuruq time as a date
  DateTime? shuruq([DateTime? date]) {
    date ??= AppDateTime.now();

    final times = dayTimesStrings(date, salahOnly: false);
    if (times.length == 7) times.removeAt(0);

    return times[1].toTodayDate(date);
  }

  const Times({
    required this.jumua,
    required this.jumua2,
    required this.aidPrayerTime,
    required this.aidPrayerTime2,
    required this.hijriAdjustment,
    required this.hijriDateForceTo30,
    required this.jumuaAsDuhr,
    required this.imsakNbMinBeforeFajr,
    // required this.times,
    required this.calendar,
    required this.iqamaCalendar,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Times &&
          runtimeType == other.runtimeType &&
          jumua == other.jumua &&
          jumua2 == other.jumua2 &&
          aidPrayerTime == other.aidPrayerTime &&
          aidPrayerTime2 == other.aidPrayerTime2 &&
          hijriAdjustment == other.hijriAdjustment &&
          hijriDateForceTo30 == other.hijriDateForceTo30 &&
          jumuaAsDuhr == other.jumuaAsDuhr &&
          imsakNbMinBeforeFajr == other.imsakNbMinBeforeFajr &&
          calendar == other.calendar &&
          iqamaCalendar == other.iqamaCalendar);

  @override
  int get hashCode =>
      jumua.hashCode ^
      jumua2.hashCode ^
      aidPrayerTime.hashCode ^
      aidPrayerTime2.hashCode ^
      hijriAdjustment.hashCode ^
      hijriDateForceTo30.hashCode ^
      jumuaAsDuhr.hashCode ^
      imsakNbMinBeforeFajr.hashCode ^
      calendar.hashCode ^
      iqamaCalendar.hashCode;

  @override
  String toString() {
    return 'Times{' +
        ' jumua: $jumua,' +
        ' jumua2: $jumua2,' +
        ' aidPrayerTime: $aidPrayerTime,' +
        ' aidPrayerTime2: $aidPrayerTime2,' +
        ' hijriAdjustment: $hijriAdjustment,' +
        ' hijriDateForceTo30: $hijriDateForceTo30,' +
        ' jumuaAsDuhr: $jumuaAsDuhr,' +
        ' imsakNbMinBeforeFajr: $imsakNbMinBeforeFajr,' +
        ' calendar: $calendar,' +
        ' iqamaCalendar: $iqamaCalendar,' +
        '}';
  }

  factory Times.fromMap(Map<String, dynamic> map) {
    /// if the jumua is null and jumua2 is not null, we use jumua2 as jumua
    String? replacedJumua = (map['jumua'] == null && map['jumua2'] != null) ? null : map['jumua2'];
    return Times(
      jumua: map['jumua'] ?? map['jumua2'],
      jumua2: replacedJumua,
      aidPrayerTime: map['aidPrayerTime'],
      aidPrayerTime2: map['aidPrayerTime2'],
      hijriAdjustment: map['hijriAdjustment'] ?? -1,
      hijriDateForceTo30: map['hijriDateForceTo30'] ?? false,
      jumuaAsDuhr: map['jumuaAsDuhr'] ?? false,
      imsakNbMinBeforeFajr: map['imsakNbMinBeforeFajr'] ?? 0,
      calendar: map['calendar'],
      iqamaCalendar: map['iqamaCalendar'],
    );
  }

//</editor-fold>
}
