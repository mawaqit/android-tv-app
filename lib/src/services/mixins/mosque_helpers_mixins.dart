import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mawaqit/src/helpers/AppDate.dart';
import 'package:mawaqit/src/helpers/StringUtils.dart';
import 'package:mawaqit/src/helpers/time_utils.dart';
import 'package:mawaqit/src/models/announcement.dart';
import 'package:mawaqit/src/models/calendar/MawaqitHijriCalendar.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';

import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/models/mosque.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';
import 'package:mawaqit/src/models/times.dart';

mixin MosqueHelpersMixin on ChangeNotifier {
  abstract Mosque? mosque;
  abstract Times? times;
  abstract MosqueConfig? mosqueConfig;

  /// this will be set from the [NetworkConnectivity] mixin
  /// because we use in the [activeAnnouncements] getter
  bool get isOnline;

  /// [salahNames] getter is used to get the names of the prayers in the current language
  List<String> get salahNames => [
        times?.isTurki ?? false ? S.current.sabah : S.current.fajr,
        S.current.duhr,
        S.current.asr,
        S.current.maghrib,
        S.current.isha,
      ];

  /// [salahName] it uses the [salahNames] getter to get the name of the prayer in the current language
  String salahName(int index) => salahNames[index];

  /// [getSalahNameByIndex] it uses the [salahNames] getter to get the name of the prayer in the current language
  String getSalahNameByIndex(int index, BuildContext context) {
    return [
      times!.isTurki ? S.of(context).sabah : S.of(context).fajr,
      S.of(context).duhr,
      S.of(context).asr,
      S.of(context).maghrib,
      S.of(context).isha,
    ][index];
  }

  /// Checks if the Hadith feature should be disabled based on the current Salah time.
  /// The disabling rule is defined in the mosque configuration.
  ///
  /// Returns `true` if the Hadith feature is disabled for the current Salah time.
  bool isDisableHadithBetweenSalah() {
    (int, int)? periods = _parseDisablingPeriods(mosqueConfig?.randomHadithIntervalDisabling ?? '');

    if (periods == null) {
      return false;
    }
    return salahIndex >= periods.$1 && salahIndex < periods.$2;
  }

  /// Parses the start and end periods from the disabling interval configuration.
  /// Returns a `tuple` containing the start and end periods, or `null` if parsing fails.
  (int, int)? _parseDisablingPeriods(String config) {
    if (!config.contains('-')) {
      return null;
    }

    List<String> parts = config.split('-');
    int? startPeriod = int.tryParse(parts[0]);
    int? endPeriod = int.tryParse(parts[1]);

    if (startPeriod == null || endPeriod == null) {
      return null;
    }

    return (startPeriod, endPeriod);
  }

  bool adhanVoiceEnable([int? salahIndex]) {
    salahIndex ??= this.salahIndex;

    return mosqueConfig?.adhanEnabledByPrayer?[salahIndex] == '1' && (mosqueConfig?.adhanVoice?.isNotEmpty ?? false);
  }

  bool get isAdhanVoiceEnabled => adhanVoiceEnable();
  int get salahIndex => (nextSalahIndex() - 1) % 5;

  bool get isImsakEnabled {
    return times!.imsakNbMinBeforeFajr != 0;
  }

  bool get isShurukTime {
    final shrukDate = times?.shuruq(AppDateTime.now());

    if (shrukDate == null) return false;

    return AppDateTime.now().isAfter(actualTimes()[0]) && AppDateTime.now().isBefore(shrukDate);
  }

  String getShurukInString(BuildContext context) {
    final shurukTime = times!.shuruq(AppDateTime.now())!.difference(AppDateTime.now());
    return StringManager.getCountDownText(context, shurukTime, S.of(context).shuruk);
  }

  String? getShurukTimeString([DateTime? date]) {
    final shuruq = times!.shuruq(AppDateTime.now());

    if (shuruq == null) return null;

    return DateFormat('HH:mm').format(shuruq);
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
  List<DateTime> actualTimes([DateTime? date]) {
    date ??= mosqueDate();

    return timesOfDay(date).map((e) => e.toTimeOfDay()!.toDate(date)).toList();
  }

  /// get today iqama prayer times as a list of times
  List<DateTime> actualIqamaTimes([DateTime? date]) {
    date ??= mosqueDate();

    final times = actualTimes(date);
    return iqamasOfDay(date).mapIndexed((i, e) => e.toTimeOfDay(tryOffset: times[i])!.toDate(date)).toList();
  }

  /// return the upcoming salah index
  /// return -1 in case of issue(invalid times format)
  int nextIqamaIndex() {
    final now = mosqueDate();
    final iqamaTimes = actualIqamaTimes();
    final fajrTime = iqamaTimes[0];

    // Convert time to minutes since start of day
    int toMinutes(DateTime time) {
      // If time is after midnight but before Fajr, add 24 hours
      if (time.hour < fajrTime.hour || (time.hour == fajrTime.hour && time.minute < fajrTime.minute)) {
        return (time.hour + 24) * 60 + time.minute;
      }
      return time.hour * 60 + time.minute;
    }

    // Get minutes for current time
    int nowMinutes = toMinutes(now);

    // Convert iqama times to minutes and handle after-midnight cases
    List<int> timeMinutes = iqamaTimes.mapIndexed((index, time) {
      // For Isha prayer (index 4), if it's very early (e.g. 1:00), treat it as next day
      if ((index == 4 || index == 3) && time.hour < fajrTime.hour) {
        return (time.hour + 24) * 60 + time.minute;
      }
      return time.hour * 60 + time.minute;
    }).toList();

    // Find next iqama
    int nextIndex = timeMinutes.indexWhere((minutes) => minutes > nowMinutes);

    // If no next iqama found today, return Fajr (0)
    return nextIndex == -1 ? 0 : nextIndex;
  }

  /// return the upcoming salah index
  /// return -1 in case of issue(invalid times format)
  int nextSalahIndex() {
    final now = mosqueDate();
    final times = actualTimes();
    final fajrTime = times[0];

    // Convert time to minutes since start of day
    int toMinutes(DateTime time) {
      // If time is after midnight but before Fajr, add 24 hours
      if (time.hour < fajrTime.hour || (time.hour == fajrTime.hour && time.minute < fajrTime.minute)) {
        return (time.hour + 24) * 60 + time.minute;
      }
      return time.hour * 60 + time.minute;
    }

    // Get minutes for current time
    int nowMinutes = toMinutes(now);

    // Convert prayer times to minutes and handle after-midnight cases
    List<int> timeMinutes = times.mapIndexed((index, time) {
      // For Isha prayer (index 4), if it's very early (e.g. 1:00), treat it as next day
      if ((index == 4 || index == 3) && time.hour < fajrTime.hour) {
        return (time.hour + 24) * 60 + time.minute;
      }
      return time.hour * 60 + time.minute;
    }).toList();

    // Find next prayer
    int nextIndex = timeMinutes.indexWhere((minutes) => minutes > nowMinutes);

    // If no next prayer found today, return Fajr (0)
    return nextIndex == -1 ? 0 : nextIndex;
  }

  /// return the upcoming salah index
  /// return -1 in case of issue(invalid times format)
  int nextSalahAfterIqamaIndex() {
    final now = mosqueDate();
    final times = actualIqamaTimes();

    // Convert time to minutes since midnight for easier comparison
    int toMinutes(DateTime time, DateTime fajrTime) {
      // If current time is before fajr and after midnight,
      // or if prayer time is before fajr, add 24 hours
      bool isAfterMidnight = time.hour < fajrTime.hour || (time.hour == fajrTime.hour && time.minute < fajrTime.minute);

      int hours = isAfterMidnight ? time.hour + 24 : time.hour;
      return hours * 60 + time.minute;
    }

    // Get minutes since midnight for current time
    int nowMinutes = toMinutes(now, times[0]);

    // Convert prayer times to minutes
    List<int> timeMinutes = times.map((t) {
      bool isBeforeFajr = t.hour < times[0].hour || (t.hour == times[0].hour && t.minute <= times[0].minute);
      return isBeforeFajr ? toMinutes(t, times[0]) : t.hour * 60 + t.minute;
    }).toList();

    // Find the next prayer time
    final nextIndex = timeMinutes.indexWhere((t) => t > nowMinutes);

    // If no next prayer found today, return first prayer (Fajr)
    return nextIndex == -1 ? 0 : nextIndex;
  }

  /// the duration until the next salah
  Duration nextSalahAfter() {
    final now = mosqueDate();
    final nextIndex = nextSalahIndex();
    final nextTime = actualTimes()[nextIndex];
    final fajrTime = actualTimes()[0];

    // Handle Maghrib or Isha after midnight
    if ((nextIndex == 3 || nextIndex == 4) &&
        (nextTime.hour < fajrTime.hour || (nextTime.hour == fajrTime.hour && nextTime.minute < fajrTime.minute))) {
      // For after midnight case (e.g. current time is 00:01)
      if (now.hour < 12) {
        final minutes = 60 - now.minute + (nextTime.hour - (now.hour + 1)) * 60 + nextTime.minute;
        return Duration(minutes: minutes);
      }

      // For before midnight case (e.g. current time is 23:50)
      final prayerTime = DateTime(
          now.year,
          now.month,
          now.day + 1, // Add 1 day since it's for tomorrow
          nextTime.hour,
          nextTime.minute);
      return prayerTime.difference(now);
    }

    // For all other cases, use normal difference
    final duration = nextTime.difference(now);
    if (duration < Duration.zero) {
      final tomorrowFajr = tomorrowTimes[0].toTimeOfDay()!.toDate(now.add(Duration(days: 1)));
      return tomorrowFajr.difference(now);
    }
    return duration;
  }

  /// the duration until the next iqama
  Duration nextIqamaaAfter() {
    final now = mosqueDate();
    final nextIndex = nextIqamaIndex();
    final nextTime = actualIqamaTimes()[nextIndex];
    final fajrTime = actualIqamaTimes()[0];

    // Handle Maghrib or Isha Iqama times after midnight
    if ((nextIndex == 3 || nextIndex == 4) &&
        (nextTime.hour < fajrTime.hour || (nextTime.hour == fajrTime.hour && nextTime.minute < fajrTime.minute))) {
      // For after midnight case (e.g. current time is 00:01)
      if (now.hour < 12) {
        final minutes = 60 - now.minute + (nextTime.hour - (now.hour + 1)) * 60 + nextTime.minute;
        return Duration(minutes: minutes, seconds: 60 - now.second);
      }

      // For before midnight case (e.g. current time is 23:50)
      final iqamaTime = DateTime(now.year, now.month, now.day + 1, nextTime.hour, nextTime.minute, 0);
      return iqamaTime.difference(now);
    }

    // For all other cases, use normal difference
    final duration = DateTime(now.year, now.month, now.day, nextTime.hour, nextTime.minute, 0).difference(now);

    if (duration < Duration.zero) {
      // Check if the iqama is set to 0 (no delay)
      final todayIqamas = iqamasOfDay(mosqueDate());
      final currentSalahIndex = salahIndex;
      final currentIqamaString = todayIqamas[currentSalahIndex];
      final currentIqamaMinutes = int.tryParse(currentIqamaString) ?? 0;

      // If iqama is 0, show 3-minute countdown from prayer time
      if (currentIqamaMinutes == 0) {
        final currentPrayerTime = actualTimes()[currentSalahIndex];
        final timeSincePrayer = now.difference(currentPrayerTime);
        final remainingTime = Duration(minutes: 3) - timeSincePrayer;

        // Always return the remaining time, even if it goes below zero
        return remainingTime > Duration.zero ? remainingTime : Duration.zero;
      }

      final tomorrowFajr =
          DateTime(now.year, now.month, now.day + 1, actualIqamaTimes()[0].hour, actualIqamaTimes()[0].minute, 0);
      return tomorrowFajr.difference(now);
    }
    return duration;
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
  TimeOfDay mosqueTimeOfDay() => TimeOfDay.fromDateTime(mosqueDate());

  @Deprecated('Use AppDateTime.now()')
  DateTime mosqueDate() => AppDateTime.now();

  MawaqitHijriCalendar mosqueHijriDate(int? forceAdjustment) => MawaqitHijriCalendar.fromDateWithAdjustments(
        mosqueDate(),
        force30Days: times!.hijriDateForceTo30,
        adjustment: forceAdjustment ?? times!.hijriAdjustment,
      );

  bool get useTomorrowTimes {
    final ishaIndex = 4;
    final now = mosqueDate();
    final [fajr, ..._] = actualTimes();
    final ishaIqamaTime = actualIqamaTimes()[ishaIndex];
    final salahIshaDuration = mosqueConfig?.duaAfterPrayerShowTimes[ishaIndex];
    final salahIshaEndTime;
    //Get isha end salat time
    if (mosqueConfig?.iqamaEnabled == true) {
      salahIshaEndTime = ishaIqamaTime.add(
        Duration(minutes: int.tryParse(salahIshaDuration!) ?? 20),
      );
    } else {
      salahIshaEndTime = ishaIqamaTime.add(
        Duration(minutes: 20),
      );
    }
    // Isha might be after midnight, so we need to check if it's after Fajr
    return now.isAfter(salahIshaEndTime) && salahIshaEndTime.isAfter(fajr);
  }

  /// @Param [forceActualDuhr] force to use actual duhr time instead of jumua time during the friday
  List<String> timesOfDay(DateTime date, {bool forceActualDuhr = false}) {
    List<String> t = times!.dayTimesStrings(date);

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

  @Deprecated('User Times.dayIqamaStrings')
  List<String> iqamasOfDay(DateTime date) => times!.dayIqamaStrings(date);

  @Deprecated('Use times.dayIqamaStrings')
  List<String> get todayIqama => iqamasOfDay(mosqueDate());

  @Deprecated('Use times.dayIqamaStrings')
  List<String> get tomorrowIqama => iqamasOfDay(mosqueDate().add(Duration(days: 1)));

/*   /// if jumua as duhr return jumua
  String? get jumuaTime {
    return times!.jumuaAsDuhr ? todayTimes[1] : times!.jumua;
  } */

  /// Calculates the next Friday date from the given date
  /// If no date is provided, it uses the current mosque date
  DateTime nextFridayDate([DateTime? now]) {
    now ??= mosqueDate();
    return now.add(Duration(days: (7 - now.weekday + DateTime.friday) % 7));
  }

  /// Returns ordered Jumua times for display
  /// This method handles both jumuaAsDuhr case and normal case with multiple jumua times
  List<String> getOrderedJumuaTimes() {
    List<String> jumuaTimes = [];

    // Handle jumuaAsDuhr case
    if (times?.jumuaAsDuhr == true) {
      final nextFriday = nextFridayDate();
      final duhrTime = timesOfDay(nextFriday, forceActualDuhr: true)[1];
      jumuaTimes.add(duhrTime);
    } else {
      // Normal case - use configured Jumua times
      if (times?.jumua != null) jumuaTimes.add(times!.jumua!);
    }
    if (times?.jumua2 != null) jumuaTimes.add(times!.jumua2!);
    if (times?.jumua3 != null) jumuaTimes.add(times!.jumua3!);
    return jumuaTimes;
  }

  /// Returns the active Jumua time for the next Friday
  /// This is used for workflow and timing calculations
  DateTime activeJumuaaDate([DateTime? now]) {
    final nextFriday = nextFridayDate(now);
    final jumuaTimes = getOrderedJumuaTimes();
    if (jumuaTimes.isEmpty) {
      return nextFriday;
    }

    // Use the first Jumua time
    return jumuaTimes[0].toTimeOfDay()!.toDate(nextFriday);
  }

  /// Checks if we are currently in Jumua workflow time
  bool jumuaaWorkflowTime() {
    final now = mosqueDate();
    final jumuaaStartTime = activeJumuaaDate();
    final jumuaaEndTime = jumuaaStartTime.add(
      Duration(minutes: mosqueConfig?.jumuaTimeout ?? 30) + kAzkarDuration,
    );

    if (now.weekday != DateTime.friday) return false;
    if (!typeIsMosque) return false;

    return now.isAfter(jumuaaStartTime) && now.isBefore(jumuaaEndTime);
  }

  /// if the iqama is less than 2min
  bool isShortIqamaDuration(int salahIndex) {
    final iqamaa = iqamasOfDay(mosqueDate());

    final currentIqamaa = iqamaa[salahIndex];
    final currentIqamaDuration = int.tryParse(currentIqamaa) ?? 5;

    return currentIqamaDuration <= 2;
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
    final announcements = mosque!.announcements.where((element) {
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
    // check if announcement has only youtube video, add another one for infinite loop
    if (announcements.length == 1 && announcements[0].video != null) {
      announcements.add(announcements[0]);
    }
    return announcements;
  }
}
