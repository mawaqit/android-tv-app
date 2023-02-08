import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:mawaqit/src/enum/home_active_screen.dart';
import 'package:mawaqit/src/helpers/StringUtils.dart';
import 'package:mawaqit/src/helpers/time_utils.dart';
import 'package:mawaqit/src/models/MawaqitHijriCalendar.dart';
import 'package:mawaqit/src/models/announcement.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';

import '../../../generated/l10n.dart';
import '../../models/mosque.dart';
import '../../models/mosqueConfig.dart';
import '../../models/times.dart';

/// used to speed up the work flows in
const kTestDurationFactor = kDebugMode ? 1 / 10 : 1;

mixin MosqueHelpersMixin on ChangeNotifier {
  abstract Mosque? mosque;
  abstract Times? times;
  abstract MosqueConfig? mosqueConfig;

  abstract HomeActiveWorkflow workflow;

  salahName(int index) => [
        S.current.fajr,
        S.current.duhr,
        S.current.asr,
        S.current.maghrib,
        S.current.isha,
      ][index];

  calculateActiveWorkflow() {
    if (jumuaaWorkflowTime()) {
      workflow = HomeActiveWorkflow.jumuaa;
    } else if (salahWorkflow()) {
      workflow = HomeActiveWorkflow.salah;
    } else {
      workflow = HomeActiveWorkflow.normal;
    }

    notifyListeners();
  }

  backToNormalHomeScreen() {
    workflow = HomeActiveWorkflow.normal;
    notifyListeners();
  }

  startSalahWorkflow() {
    if (nextSalahIndex() == 1 && mosqueDate().weekday == DateTime.friday) {
      workflow = HomeActiveWorkflow.jumuaa;
    } else {
      workflow = HomeActiveWorkflow.salah;
    }

    notifyListeners();
  }

  bool isDisableHadithBetweenSalah() {
    if (mosqueConfig?.randomHadithIntervalDisabling != null) {
      if (mosqueConfig!.randomHadithIntervalDisabling!.isNotEmpty) {
        final twoSalahIndex =
            mosqueConfig?.randomHadithIntervalDisabling!.split("-");
        int firstSalahIndex = int.parse(twoSalahIndex!.first);
        return salahIndex == firstSalahIndex;
      }
    }
    return false;
  }

  get salahIndex => (nextSalahIndex() - 1) % 5;

  bool get activateShroukItem {
    final shuruqTimeInMinutes = times?.shuruq?.toTimeOfDay()?.inMinutes;
    final duhrTime = todayTimes[1].toTimeOfDay()?.inMinutes;
    final nowInMinutes = mosqueTimeOfDay().inMinutes;
    if (shuruqTimeInMinutes == null || duhrTime == null) return false;

    return nowInMinutes >= shuruqTimeInMinutes && nowInMinutes <= duhrTime;
  }

  bool isShurukTime() {
    final shrukDate = times?.shuruq?.toTimeOfDay()?.toDate(mosqueDate());

    if (shrukDate == null) return false;

    return mosqueDate().isAfter(actualTimes()[0]) &&
        mosqueDate().isBefore(shrukDate);
  }

  String getShurukInString(BuildContext context) {
    final shurukTime = times!.shuruq!
        .toTimeOfDay()!
        .toDate(mosqueDate())
        .difference(mosqueDate());
    return StringManager.getCountDownText(
        context, shurukTime, S.of(context).shuruk);
  }

  /// show imsak between midnight and fajr
  bool get showImsak {
    final now = mosqueDate();
    final midnight = DateUtils.dateOnly(now);
    final fajrDate = actualTimes()[0];

    return now.isAfter(midnight) && now.isBefore(fajrDate);
  }

  bool get typeIsMosque {
    return mosque?.type == "MOSQUE";
  }

  bool get showEid {
    if (times!.aidPrayerTime == null && times!.aidPrayerTime2 == null) {
      return false;
    }
    return (((mosqueHijriDate().hMonth == 9 && mosqueHijriDate().hDay >= 23) ||
            (mosqueHijriDate().hMonth == 10 && mosqueHijriDate().hDay == 1)) ||
        (mosqueHijriDate().hMonth == 12 && mosqueHijriDate().hDay < 11));
  }

  /// get today salah prayer times as a list of times
  List<DateTime> actualTimes() =>
      todayTimes.map((e) => e.toTimeOfDay()!.toDate(mosqueDate())).toList();

  /// get today iqama prayer times as a list of times
  List<DateTime> actualIqamaTimes() => [
        for (var i = 0; i < 5; i++)
          todayIqama[i]
              .toTimeOfDay(
                tryOffset: todayTimes[i].toTimeOfDay()!.toDate(mosqueDate()),
              )!
              .toDate(mosqueDate()),
      ];

  /// return the upcoming salah index
  /// return -1 in case of issue(invalid times format)
  int nextIqamaIndex() {
    final now = mosqueDate();
    final nextIqama = actualIqamaTimes().firstWhere(
      (element) => element.isAfter(now),
      orElse: () => actualIqamaTimes().first,
    );

    return actualIqamaTimes().indexOf(nextIqama);
  }

  /// return the upcoming salah index
  /// return -1 in case of issue(invalid times format)
  int nextSalahIndex() {
    final now = mosqueDate();
    final nextSalah = actualTimes().firstWhere(
      (element) => element.isAfter(now),
      orElse: () => actualTimes().first,
    );
    var salahIndex = actualTimes().indexOf(nextSalah);
    if (salahIndex > 4) salahIndex = 0;
    if (salahIndex < 0) salahIndex = 4;
    return salahIndex;
  }

  /// the duration until the next salah
  Duration nextSalahAfter() {
    final duration = actualTimes()[nextSalahIndex()].difference(mosqueDate());

    if (duration < Duration.zero) return duration + Duration(days: 1);
    return duration;
  }

  /// the duration until the next salah
  Duration nextIqamaaAfter() =>
      actualIqamaTimes()[nextIqamaIndex()].difference(mosqueDate());

  /// return actual salah duration
  Duration get currentSalahDuration {
    if (mosqueConfig == null) return Duration.zero;

    return Duration(
        minutes:
            int.tryParse(mosqueConfig!.duaAfterPrayerShowTimes[salahIndex]) ??
                10);
  }

  String get imsak {
    try {
      int minutes = int.parse(todayTimes.first.split(':').first) * 60 +
          int.parse(todayTimes.first.split(':').last) -
          times!.imsakNbMinBeforeFajr;

      String _timeTwoDigit = timeTwoDigit(
        seconds: minutes % 60,
        minutes: minutes ~/ 60,
      );
      return _timeTwoDigit;
      // return DateFormat('HH:mm').format(DateTime(200, 1, 1, minutes ~/ 60, minutes % 60));
    } catch (e, stack) {
      debugPrintStack(stackTrace: stack);
      return '';
    }
  }

  /// used to test time
  DateTime mosqueDate() =>
      !kDebugMode ? DateTime.now() : DateTime.now().add(Duration(hours: 2 , minutes: 56));

  /// used to test time
  TimeOfDay mosqueTimeOfDay() => TimeOfDay.fromDateTime(mosqueDate());

  HijriCalendar mosqueHijriDate() => MawaqitHijriCalendar.fromDate(mosqueDate().add(
        Duration(
          days: times!.hijriAdjustment,
        ),
      ));

  bool get useTomorrowTimes {
    final now = mosqueDate();
    final isha = actualTimes()[4];

    return now.isAfter(isha);
  }

  timesOfDay(DateTime date) {
    List<String> t =
        times!.calendar[date.month - 1][date.day.toString()].cast<String>();

    if (t.length >= 6) t.removeAt(1);
    if (t.length > 5) t = t.sublist(0, 5);

    return t;
  }

  List<String> get todayTimes => timesOfDay(mosqueDate());

  List<String> get tomorrowTimes =>
      timesOfDay(mosqueDate().add(Duration(days: 1)));

  List<String> iqamasOfDay(DateTime date) {
    final todayIqama = times!.iqamaCalendar[mosqueDate().month - 1]
            [mosqueDate().day.toString()]
        .cast<String>();

    if (mosqueDate().weekday == DateTime.friday) {
      todayIqama[1] = "+30";
    }
    return todayIqama;
  }

  List<String> get todayIqama => iqamasOfDay(mosqueDate());

  List<String> get tomorrowIqama =>
      iqamasOfDay(mosqueDate().add(Duration(days: 1)));

  String? get jumuaaLiveUrl => null;

  /// if jumua as duhr return jumua
  String? get jumuaTime {
    return times!.jumuaAsDuhr ? todayTimes[1] : times!.jumua;
  }

  /// we are in jumuaa workflow time
  bool jumuaaWorkflowTime() {
    final now = mosqueDate();
    final jumuaaStartTime = jumuaTime?.toTimeOfDay()?.toDate();
    final jumuaaEndTime = jumuaaStartTime?.add(
      Duration(minutes: mosqueConfig?.jumuaTimeout ?? 30) + kAzkarDuration,
    );

    if (now.weekday != DateTime.friday) return false;
    if (!typeIsMosque) return false;
    if (jumuaaStartTime == null) return false;

    if (now.isBefore(jumuaaStartTime) || now.isAfter(jumuaaEndTime!))
      return false;

    return true;
  }

  /// starting from before salah 5min until after the salah and azker
  bool salahWorkflow() {
    final now = mosqueDate();

    final lastIqamaIndex = (nextIqamaIndex() - 1) % 5;
    var lastIqamaTime = actualIqamaTimes()[lastIqamaIndex];
    if (lastIqamaTime.isAfter(now))
      lastIqamaTime =
          lastIqamaTime.subtract(Duration(days: 1) * kTestDurationFactor);

    final salahDuration = mosqueConfig!.duaAfterPrayerShowTimes[lastIqamaIndex];
    final salahAndAzkarEndTime = lastIqamaTime.add(
      Duration(minutes: int.tryParse(salahDuration) ?? 0) + kAzkarDuration,
    );

    if (nextSalahAfter() < Duration(minutes: 5)) return true;

    /// we are in time between salah and iqama
    if (nextSalahIndex() != nextIqamaIndex()) return true;

    if (now.isBefore(salahAndAzkarEndTime) && now.isAfter(lastIqamaTime))
      return true;

    return false;
  }

  /// remove videos in case of mosque screen
  /// todo check for primary/secondary screen
  List<Announcement> get activeAnnouncements {
    return mosque!.announcements.where((element) {
      final startDate = DateTime.tryParse(element.startDate ?? '');
      final endDate = DateTime.tryParse(element.endDate ?? '');
      final now = mosqueDate();

      final inTime = now.isAfter(startDate ?? DateTime(2000)) &&
          now.isBefore(endDate ?? DateTime(3000));

      return (element.video == null || !typeIsMosque) && inTime;
    }).toList();
  }
}
