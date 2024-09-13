import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mawaqit/src/helpers/AppDate.dart';
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

    // Adjust the last prayer time (Isha) to be on the next day if it's at midnight
    if (iqamaTimes.last.hour == 0 && iqamaTimes.last.minute == 0) {
      iqamaTimes[iqamaTimes.length - 1] = iqamaTimes.last.add(Duration(days: 1));
    }

    final nextIqama = iqamaTimes.firstWhere(
      (element) => element.isAfter(now),
      orElse: () => iqamaTimes.first,
    );

    return iqamaTimes.indexOf(nextIqama);
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

  DateTime nextFridayDate([DateTime? now]) {
    now ??= mosqueDate();

    return now.add(Duration(days: (7 - now.weekday + DateTime.friday) % 7));
  }

  /// cases 1: if Jumuaa is as Duhr return Duhr pray of the day.
  /// cases 2: if Jumuaa is not as Duhr and both jumuaa and jumuaa2 are empty return next friday date.
  /// cases 3: if Jumuaa is not as Duhr and jumuaa or jumuaa2 is not empty return *jumuaa1* time.
  DateTime activeJumuaaDate([DateTime? now]) {
    final nextFriday = nextFridayDate(now);
    if (times!.jumuaAsDuhr == true) return timesOfDay(nextFriday)[1].toTimeOfDay()!.toDate(nextFriday);
    if (isJumuaOrJumua2EmptyOrNull()) {
      return nextFriday;
    }

    final jumuaaTime = times!.jumua; // return jumuaa1 time
    return jumuaaTime!.toTimeOfDay()!.toDate(nextFriday); // parsing the value of juma to time of day and then to date
  }

  bool isJumuaOrJumua2EmptyOrNull() {
    return (times?.jumua ?? '').isEmpty && (times?.jumua2 ?? '').isEmpty;
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
    final jumuaaStartTime = activeJumuaaDate();
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
