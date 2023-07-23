import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mawaqit/src/enum/home_active_screen.dart';
import 'package:mawaqit/src/helpers/StringUtils.dart';
import 'package:mawaqit/src/helpers/time_utils.dart';
import 'package:mawaqit/src/models/announcement.dart';
import 'package:mawaqit/src/models/calendar/MawaqitHijriCalendar.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';

import '../../../i18n/l10n.dart';
import '../../models/mosque.dart';
import '../../models/mosqueConfig.dart';
import '../../models/times.dart';

mixin MosqueHelpersMixin on ChangeNotifier {
  abstract Mosque? mosque;
  abstract Times? times;
  abstract MosqueConfig? mosqueConfig;

  abstract HomeActiveWorkflow workflow;

  /// this will be set from the [NetworkConnectivity] mixin
  /// because we use in the [activeAnnouncements] getter
  bool get isOnline;

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
    if (nextIqamaIndex() == 1 && mosqueDate().weekday == DateTime.friday && typeIsMosque) {
      workflow = HomeActiveWorkflow.jumuaa;
    } else {
      workflow = HomeActiveWorkflow.salah;
    }

    notifyListeners();
  }

  bool isDisableHadithBetweenSalah() {
    final disableTime = mosqueConfig?.randomHadithIntervalDisabling ?? '';
    final disabledHadithPeriod = int.tryParse(disableTime.split('-').first);

    return disabledHadithPeriod == salahIndex;
  }

  bool adhanVoiceEnable([int? salahIndex]) {
    salahIndex ??= this.salahIndex;

    return mosqueConfig?.adhanEnabledByPrayer?[salahIndex] == '1' && (mosqueConfig?.adhanVoice?.isNotEmpty ?? false);
  }

  int get salahIndex => (nextSalahIndex() - 1) % 5;

  bool get isImsakEnabled {
    return times!.imsakNbMinBeforeFajr != 0;
  }

  bool get isShurukTime {
    final shrukDate = times?.shuruq?.toTimeOfDay()?.toDate(mosqueDate());

    if (shrukDate == null) return false;

    return mosqueDate().isAfter(actualTimes()[0]) && mosqueDate().isBefore(shrukDate);
  }

  String getShurukInString(BuildContext context) {
    final shurukTime = times!.shuruq!.toTimeOfDay()!.toDate(mosqueDate()).difference(mosqueDate());
    return StringManager.getCountDownText(context, shurukTime, S.of(context).shuruk);
  }

  String? getShurukTimeString([DateTime? date]) {
    date ??= mosqueDate();
    if (useTomorrowTimes) date = date.add(Duration(days: 1));

    final t = List.from(times!.calendar[date.month - 1][date.day.toString()]);

    if (t.length == 5) return times!.shuruq;

    return t[1];
  }

  bool get typeIsMosque {
    return mosque?.type == "MOSQUE";
  }

  /// return true if today is the eid first day
  bool isEidFirstDay(int? hijriAdjustment) {
    final hijri = mosqueHijriDate(hijriAdjustment);

    return (hijri.islamicMonth == 9 && hijri.islamicDate == 1) || (hijri.islamicMonth == 11 && hijri.islamicDate == 10);
  }

  bool showEid(int? hijriAdjustment) {
    if (times!.aidPrayerTime == null && times!.aidPrayerTime2 == null) return false;

    final date = mosqueHijriDate(hijriAdjustment);
    return (date.islamicMonth == 8 && date.islamicDate >= 23) ||
        (date.islamicMonth == 9 && date.islamicDate == 1) ||
        (date.islamicMonth == 11 && date.islamicDate < 11 && date.islamicDate >= 3);
  }

  /// get today salah prayer times as a list of times
  List<DateTime> actualTimes() => todayTimes.map((e) => e.toTimeOfDay()!.toDate(mosqueDate())).toList();

  /// get today iqama prayer times as a list of times
  List<DateTime> actualIqamaTimes() => [
        for (var i = 0; i < 5; i++)
          todayIqama[i]
              .toTimeOfDay(
                tryOffset: todayTimes[i].toTimeOfDay()!.toDate(mosqueDate()),
                // minimumMinutes: 3,
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
    final now = mosqueDate();
    final duration = actualTimes()[nextSalahIndex()].difference(now);

    /// next salah is tomorrow fajr
    if (duration < Duration.zero) {
      final tomorrowFajr = tomorrowTimes[0].toTimeOfDay()!.toDate(now.add(Duration(days: 1)));

      return tomorrowFajr.difference(now);
    }
    return duration;
  }

  /// the duration until the next salah
  Duration nextIqamaaAfter() {
    final value = actualIqamaTimes()[nextIqamaIndex()].difference(mosqueDate());

    if (value < Duration.zero) return value + Duration(days: 1);
    return value;
  }

  /// return actual salah duration
  Duration get currentSalahDuration {
    if (mosqueConfig == null) return Duration.zero;

    return Duration(
      minutes: int.tryParse(mosqueConfig!.duaAfterPrayerShowTimes[salahIndex]) ?? 10,
    );
  }

  /// after fajr show imsak for tomorrow
  String get imsak {
    try {
      final now = mosqueDate();

      String tomorrowFajr = todayTimes[0];

      /// when we are bettween midnight and fajr show today imsak
      /// otherwise show tomorrow imsak
      if (now.isAfter(actualTimes()[0])) tomorrowFajr = tomorrowTimes[0];

      int minutes = tomorrowFajr.toTimeOfDay()!.inMinutes - times!.imsakNbMinBeforeFajr;

      String _timeTwoDigit = timeTwoDigit(
        seconds: minutes % 60,
        minutes: minutes ~/ 60,
      );
      return _timeTwoDigit;
    } catch (e, stack) {
      debugPrintStack(stackTrace: stack);
      return '';
    }
  }

  /// used to test time
  DateTime mosqueDate() => !kDebugMode
      ? DateTime.now()
      : DateTime.now().add(Duration(
          days: 3,
          hours: 3,
        ));

  /// used to test time
  TimeOfDay mosqueTimeOfDay() => TimeOfDay.fromDateTime(mosqueDate());

  MawaqitHijriCalendar mosqueHijriDate(int? forceAdjustment) => MawaqitHijriCalendar.fromDateWithAdjustments(
        mosqueDate(),
        force30Days: times!.hijriDateForceTo30,
        adjustment: forceAdjustment ?? times!.hijriAdjustment,
      );

  bool get useTomorrowTimes {
    final now = mosqueDate();
    final [fajr, ..._, isha] = actualTimes();

    /// isha might be after midnight so we need to check if it's after fajr
    return now.isAfter(isha) && isha.isAfter(fajr);
  }

  List<String> salahBarTimes() {
    if (useTomorrowTimes) {
      return timesOfDay(
        mosqueDate().add(1.days),
        forceActualDuhr: true,
      );
    } else {
      return timesOfDay(mosqueDate(), forceActualDuhr: true);
    }
  }

  /// @Param [forceActualDuhr] force to use actual duhr time instead of jumua time during the friday
  List<String> timesOfDay(DateTime date, {bool forceActualDuhr = false}) {
    List<String> t = List.from(times!.calendar[date.month - 1][date.day.toString()]);

    if (t.length >= 6) t.removeAt(1);
    if (t.length > 5) t = t.sublist(0, 5);

    if (date.weekday == DateTime.friday &&
        typeIsMosque &&
        times!.jumua != null &&
        times!.jumuaAsDuhr == false &&
        forceActualDuhr == false) {
      t[1] = times!.jumua!;
    }

    return t;
  }

  /// will return the salah times of the day
  /// this will modify the duhr time to jumua time if it's mosque and friday
  List<String> get todayTimes => timesOfDay(mosqueDate());

  List<String> get tomorrowTimes => timesOfDay(mosqueDate().add(Duration(days: 1)));

  List<String> iqamasOfDay(DateTime date) {
    final todayIqama = times!.iqamaCalendar[date.month - 1][date.day.toString()].cast<String>();

    return todayIqama;
  }

  List<String> get todayIqama => iqamasOfDay(mosqueDate());

  List<String> get tomorrowIqama => iqamasOfDay(mosqueDate().add(Duration(days: 1)));

  /// if jumua as duhr return jumua
  String? get jumuaTime {
    return times!.jumuaAsDuhr ? todayTimes[1] : times!.jumua;
  }

  /// if the iqama is less than 2min
  bool isShortIqamaDuration(int salahIndex) {
    final iqamaa = iqamasOfDay(mosqueDate());

    final currentIqamaa = iqamaa[salahIndex];
    final currentIqamaDuration = int.tryParse(currentIqamaa) ?? 5;

    return currentIqamaDuration <= 2;
  }

  /// we are in jumuaa workflow time
  bool jumuaaWorkflowTime() {
    final now = mosqueDate();
    final jumuaaStartTime = jumuaTime?.toTimeOfDay()?.toDate(now);
    final jumuaaEndTime = jumuaaStartTime?.add(
      Duration(minutes: mosqueConfig?.jumuaTimeout ?? 30) + kAzkarDuration,
    );

    if (now.weekday != DateTime.friday) return false;
    if (!typeIsMosque) return false;
    if (jumuaaStartTime == null) return false;

    if (now.isBefore(jumuaaStartTime) || now.isAfter(jumuaaEndTime!)) return false;

    return true;
  }

  /// starting from before salah 5min until after the salah and azker
  bool salahWorkflow() {
    final now = mosqueDate();

    final lastIqamaIndex = (nextIqamaIndex() - 1) % 5;
    var lastIqamaTime = actualIqamaTimes()[lastIqamaIndex];
    if (lastIqamaTime.isAfter(now)) lastIqamaTime = lastIqamaTime.subtract(Duration(days: 1));

    final salahDuration = mosqueConfig!.duaAfterPrayerShowTimes[lastIqamaIndex];
    final salahAndAzkarEndTime = lastIqamaTime.add(
      Duration(minutes: int.tryParse(salahDuration) ?? 0) + kAzkarDuration,
    );

    /// skip salah workflow in jumuaa duhr
    if (typeIsMosque && now.weekday == DateTime.friday && nextSalahIndex() == 1) return false;

    if (nextSalahAfter() < Duration(minutes: 5)) {
      return true;
    }

    /// we are in time between salah and iqama
    if (nextSalahIndex() != nextIqamaIndex()) return true;

    /// we are in time between iqama end and azkar start
    if (now.isBefore(salahAndAzkarEndTime) && now.isAfter(lastIqamaTime)) return true;

    return false;
  }

  List<Announcement> activeAnnouncements(bool enableVideos) {
    return mosque!.announcements.where((element) {
      final startDate = DateTime.tryParse(element.startDate ?? '');
      final endDate = DateTime.tryParse(element.endDate ?? '');
      final now = mosqueDate();

      final inTime = now.isAfter(startDate ?? DateTime(2000)) && now.isBefore(endDate ?? DateTime(3000));

      /// on offline mode we don't show videos
      if (element.video != null && !isOnline) return false;

      /// on mosque screen we don't show videos in certain conditions
      if (element.video != null && !enableVideos) return false;

      return inTime;
    }).toList();
  }
}
