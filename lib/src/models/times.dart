import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Times {
  final String jumua;
  final String jumua2;
  final String aidPrayerTime;
  final String aidPrayerTime2;
  final int hijriAdjustment;
  final bool hijriDateForceTo30;
  final bool jumuaAsDuhr;
  final int imsakNbMinBeforeFajr;
  final String shuruq;
  final List<String> times;
  final List calendar;
  final List iqamaCalendar;

  String get imsak {
    try {
      int minutes =
          int.parse(times.first.split(':').first) * 60 + int.parse(times.first.split(':').last) - imsakNbMinBeforeFajr;

      return DateFormat('HH:mm').format(DateTime(200, 1, 1, minutes ~/ 60, minutes % 60));
    } catch (e, stack) {
      debugPrintStack(stackTrace: stack);
      return '';
    }
  }

//<editor-fold desc="Data Methods">

  const Times({
    required this.jumua,
    required this.jumua2,
    required this.aidPrayerTime,
    required this.aidPrayerTime2,
    required this.hijriAdjustment,
    required this.hijriDateForceTo30,
    required this.jumuaAsDuhr,
    required this.imsakNbMinBeforeFajr,
    required this.shuruq,
    required this.times,
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
          shuruq == other.shuruq &&
          times == other.times &&
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
      shuruq.hashCode ^
      times.hashCode ^
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
        ' shuruq: $shuruq,' +
        ' times: $times,' +
        ' calendar: $calendar,' +
        ' iqamaCalendar: $iqamaCalendar,' +
        '}';
  }

  Times copyWith({
    String? jumua,
    String? jumua2,
    String? aidPrayerTime,
    String? aidPrayerTime2,
    int? hijriAdjustment,
    bool? hijriDateForceTo30,
    bool? jumuaAsDuhr,
    int? imsakNbMinBeforeFajr,
    String? shuruq,
    List<String>? times,
    List<Object>? calendar,
    List<Object>? iqamaCalendar,
  }) {
    return Times(
      jumua: jumua ?? this.jumua,
      jumua2: jumua2 ?? this.jumua2,
      aidPrayerTime: aidPrayerTime ?? this.aidPrayerTime,
      aidPrayerTime2: aidPrayerTime2 ?? this.aidPrayerTime2,
      hijriAdjustment: hijriAdjustment ?? this.hijriAdjustment,
      hijriDateForceTo30: hijriDateForceTo30 ?? this.hijriDateForceTo30,
      jumuaAsDuhr: jumuaAsDuhr ?? this.jumuaAsDuhr,
      imsakNbMinBeforeFajr: imsakNbMinBeforeFajr ?? this.imsakNbMinBeforeFajr,
      shuruq: shuruq ?? this.shuruq,
      times: times ?? this.times,
      calendar: calendar ?? this.calendar,
      iqamaCalendar: iqamaCalendar ?? this.iqamaCalendar,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jumua': this.jumua,
      'jumua2': this.jumua2,
      'aidPrayerTime': this.aidPrayerTime,
      'aidPrayerTime2': this.aidPrayerTime2,
      'hijriAdjustment': this.hijriAdjustment,
      'hijriDateForceTo30': this.hijriDateForceTo30,
      'jumuaAsDuhr': this.jumuaAsDuhr,
      'imsakNbMinBeforeFajr': this.imsakNbMinBeforeFajr,
      'shuruq': this.shuruq,
      'times': this.times,
      'calendar': this.calendar,
      'iqamaCalendar': this.iqamaCalendar,
    };
  }

  factory Times.fromMap(Map<String, dynamic> map) {
    return Times(
      jumua: map['jumua'],
      jumua2: map['jumua2'],
      aidPrayerTime: map['aidPrayerTime'],
      aidPrayerTime2: map['aidPrayerTime2'],
      hijriAdjustment: map['hijriAdjustment'],
      hijriDateForceTo30: map['hijriDateForceTo30'],
      jumuaAsDuhr: map['jumuaAsDuhr'],
      imsakNbMinBeforeFajr: map['imsakNbMinBeforeFajr'],
      shuruq: map['shuruq'],
      times: List<String>.from(map['times']),
      calendar: map['calendar'],
      iqamaCalendar: map['iqamaCalendar'],
    );
  }

//</editor-fold>
}
