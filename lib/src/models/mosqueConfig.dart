import 'package:flutter/cupertino.dart';

class MosqueConfig {
  final List<String> duaAfterPrayerShowTimes;
  final bool? hijriDateEnabled;
  final bool? duaAfterAzanEnabled;
  final bool? duaAfterPrayerEnabled;
  final int? iqamaDisplayTime;
  final bool iqamaBip;
  final String? backgroundColor;
  final bool? jumuaDhikrReminderEnabled;
  final int? jumuaTimeout;
  final bool? randomHadithEnabled;
  final bool? blackScreenWhenPraying;
  final bool? wakeForFajrTime;
  final bool? jumuaBlackScreenEnabled;
  final bool? temperatureEnabled;
  final String? temperatureUnit;
  final String? hadithLang;
  final bool? iqamaEnabled;
  final String? randomHadithIntervalDisabling;
  final String? adhanVoice;
  final List<String>? adhanEnabledByPrayer;
  final bool? footer;
  final bool? iqamaMoreImportant;
  final String? timeDisplayFormat;
  final String? backgroundType;
  final String? backgroundMotif;
  final bool? iqamaFullScreenCountdown;
  final String? theme;

//<editor-fold desc="Data Methods">

  const MosqueConfig({
    required this.duaAfterPrayerShowTimes,
    required this.hijriDateEnabled,
    required this.duaAfterAzanEnabled,
    required this.duaAfterPrayerEnabled,
    required this.iqamaDisplayTime,
    required this.iqamaBip,
    required this.backgroundColor,
    required this.jumuaDhikrReminderEnabled,
    required this.jumuaTimeout,
    required this.randomHadithEnabled,
    required this.blackScreenWhenPraying,
    required this.wakeForFajrTime,
    required this.jumuaBlackScreenEnabled,
    required this.temperatureEnabled,
    required this.temperatureUnit,
    required this.hadithLang,
    required this.iqamaEnabled,
    required this.randomHadithIntervalDisabling,
    required this.adhanVoice,
    // required this.adhanEnabledByPrayer,
    required this.footer,
    required this.iqamaMoreImportant,
    required this.timeDisplayFormat,
    required this.backgroundType,
    required this.backgroundMotif,
    required this.iqamaFullScreenCountdown,
    required this.theme,
    required this.adhanEnabledByPrayer,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MosqueConfig &&
          runtimeType == other.runtimeType &&
          duaAfterPrayerShowTimes == other.duaAfterPrayerShowTimes &&
          hijriDateEnabled == other.hijriDateEnabled &&
          duaAfterAzanEnabled == other.duaAfterAzanEnabled &&
          duaAfterPrayerEnabled == other.duaAfterPrayerEnabled &&
          iqamaDisplayTime == other.iqamaDisplayTime &&
          iqamaBip == other.iqamaBip &&
          backgroundColor == other.backgroundColor &&
          jumuaDhikrReminderEnabled == other.jumuaDhikrReminderEnabled &&
          jumuaTimeout == other.jumuaTimeout &&
          randomHadithEnabled == other.randomHadithEnabled &&
          blackScreenWhenPraying == other.blackScreenWhenPraying &&
          wakeForFajrTime == other.wakeForFajrTime &&
          jumuaBlackScreenEnabled == other.jumuaBlackScreenEnabled &&
          temperatureEnabled == other.temperatureEnabled &&
          temperatureUnit == other.temperatureUnit &&
          hadithLang == other.hadithLang &&
          iqamaEnabled == other.iqamaEnabled &&
          randomHadithIntervalDisabling == other.randomHadithIntervalDisabling &&
          adhanVoice == other.adhanVoice &&
          adhanEnabledByPrayer == other.adhanEnabledByPrayer &&
          footer == other.footer &&
          iqamaMoreImportant == other.iqamaMoreImportant &&
          timeDisplayFormat == other.timeDisplayFormat &&
          backgroundType == other.backgroundType &&
          backgroundMotif == other.backgroundMotif &&
          iqamaFullScreenCountdown == other.iqamaFullScreenCountdown &&
          theme == other.theme);

  @override
  int get hashCode =>
      duaAfterPrayerShowTimes.hashCode ^
      hijriDateEnabled.hashCode ^
      duaAfterAzanEnabled.hashCode ^
      duaAfterPrayerEnabled.hashCode ^
      iqamaDisplayTime.hashCode ^
      iqamaBip.hashCode ^
      backgroundColor.hashCode ^
      jumuaDhikrReminderEnabled.hashCode ^
      jumuaTimeout.hashCode ^
      randomHadithEnabled.hashCode ^
      blackScreenWhenPraying.hashCode ^
      wakeForFajrTime.hashCode ^
      jumuaBlackScreenEnabled.hashCode ^
      temperatureEnabled.hashCode ^
      temperatureUnit.hashCode ^
      hadithLang.hashCode ^
      iqamaEnabled.hashCode ^
      randomHadithIntervalDisabling.hashCode ^
      adhanVoice.hashCode ^
      adhanEnabledByPrayer.hashCode ^
      footer.hashCode ^
      iqamaMoreImportant.hashCode ^
      timeDisplayFormat.hashCode ^
      backgroundType.hashCode ^
      backgroundMotif.hashCode ^
      iqamaFullScreenCountdown.hashCode ^
      theme.hashCode;

  @override
  String toString() {
    return 'MosqueConfig{' +
        ' hijriDateEnabled: $hijriDateEnabled,' +
        ' duaAfterAzanEnabled: $duaAfterAzanEnabled,' +
        ' duaAfterPrayerEnabled: $duaAfterPrayerEnabled,' +
        ' iqamaDisplayTime: $iqamaDisplayTime,' +
        ' iqamaBip: $iqamaBip,' +
        ' backgroundColor: $backgroundColor,' +
        ' jumuaDhikrReminderEnabled: $jumuaDhikrReminderEnabled,' +
        ' jumuaTimeout: $jumuaTimeout,' +
        ' randomHadithEnabled: $randomHadithEnabled,' +
        ' blackScreenWhenPraying: $blackScreenWhenPraying,' +
        ' wakeForFajrTime: $wakeForFajrTime,' +
        ' jumuaBlackScreenEnabled: $jumuaBlackScreenEnabled,' +
        ' temperatureEnabled: $temperatureEnabled,' +
        ' temperatureUnit: $temperatureUnit,' +
        ' hadithLang: $hadithLang,' +
        ' iqamaEnabled: $iqamaEnabled,' +
        ' randomHadithIntervalDisabling: $randomHadithIntervalDisabling,' +
        ' adhanVoice: $adhanVoice,' +
        // ' adhanEnabledByPrayer: $adhanEnabledByPrayer,' +
        ' footer: $footer,' +
        ' iqamaMoreImportant: $iqamaMoreImportant,' +
        ' timeDisplayFormat: $timeDisplayFormat,' +
        ' backgroundType: $backgroundType,' +
        ' backgroundMotif: $backgroundMotif,' +
        ' iqamaFullScreenCountdown: $iqamaFullScreenCountdown,' +
        ' theme: $theme,' +
        '}';
  }

  MosqueConfig copyWith({
    List<String>? duaAfterPrayerShowTimes,
    bool? hijriDateEnabled,
    bool? duaAfterAzanEnabled,
    bool? duaAfterPrayerEnabled,
    int? iqamaDisplayTime,
    bool? iqamaBip,
    String? backgroundColor,
    bool? jumuaDhikrReminderEnabled,
    int? jumuaTimeout,
    bool? randomHadithEnabled,
    bool? blackScreenWhenPraying,
    bool? wakeForFajrTime,
    bool? jumuaBlackScreenEnabled,
    bool? temperatureEnabled,
    String? temperatureUnit,
    String? hadithLang,
    bool? iqamaEnabled,
    String? randomHadithIntervalDisabling,
    String? adhanVoice,
    // List<String>? adhanEnabledByPrayer,
    bool? footer,
    bool? iqamaMoreImportant,
    String? timeDisplayFormat,
    String? backgroundType,
    String? backgroundMotif,
    bool? iqamaFullScreenCountdown,
    String? theme,
  }) {
    return MosqueConfig(
      duaAfterPrayerShowTimes: duaAfterPrayerShowTimes??this.duaAfterPrayerShowTimes,
      hijriDateEnabled: hijriDateEnabled ?? this.hijriDateEnabled,
      duaAfterAzanEnabled: duaAfterAzanEnabled ?? this.duaAfterAzanEnabled,
      duaAfterPrayerEnabled: duaAfterPrayerEnabled ?? this.duaAfterPrayerEnabled,
      iqamaDisplayTime: iqamaDisplayTime ?? this.iqamaDisplayTime,
      iqamaBip: iqamaBip ?? this.iqamaBip,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      jumuaDhikrReminderEnabled: jumuaDhikrReminderEnabled ?? this.jumuaDhikrReminderEnabled,
      jumuaTimeout: jumuaTimeout ?? this.jumuaTimeout,
      randomHadithEnabled: randomHadithEnabled ?? this.randomHadithEnabled,
      blackScreenWhenPraying: blackScreenWhenPraying ?? this.blackScreenWhenPraying,
      wakeForFajrTime: wakeForFajrTime ?? this.wakeForFajrTime,
      jumuaBlackScreenEnabled: jumuaBlackScreenEnabled ?? this.jumuaBlackScreenEnabled,
      temperatureEnabled: temperatureEnabled ?? this.temperatureEnabled,
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      hadithLang: hadithLang ?? this.hadithLang,
      iqamaEnabled: iqamaEnabled ?? this.iqamaEnabled,
      randomHadithIntervalDisabling: randomHadithIntervalDisabling ?? this.randomHadithIntervalDisabling,
      adhanVoice: adhanVoice ?? this.adhanVoice,
      adhanEnabledByPrayer: adhanEnabledByPrayer ?? this.adhanEnabledByPrayer,
      footer: footer ?? this.footer,
      iqamaMoreImportant: iqamaMoreImportant ?? this.iqamaMoreImportant,
      timeDisplayFormat: timeDisplayFormat ?? this.timeDisplayFormat,
      backgroundType: backgroundType ?? this.backgroundType,
      backgroundMotif: backgroundMotif ?? this.backgroundMotif,
      iqamaFullScreenCountdown: iqamaFullScreenCountdown ?? this.iqamaFullScreenCountdown,
      theme: theme ?? this.theme,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hijriDateEnabled': this.hijriDateEnabled,
      'duaAfterAzanEnabled': this.duaAfterAzanEnabled,
      'duaAfterPrayerEnabled': this.duaAfterPrayerEnabled,
      'iqamaDisplayTime': this.iqamaDisplayTime,
      'iqamaBip': this.iqamaBip,
      'backgroundColor': this.backgroundColor,
      'jumuaDhikrReminderEnabled': this.jumuaDhikrReminderEnabled,
      'jumuaTimeout': this.jumuaTimeout,
      'randomHadithEnabled': this.randomHadithEnabled,
      'blackScreenWhenPraying': this.blackScreenWhenPraying,
      'wakeForFajrTime': this.wakeForFajrTime,
      'jumuaBlackScreenEnabled': this.jumuaBlackScreenEnabled,
      'temperatureEnabled': this.temperatureEnabled,
      'temperatureUnit': this.temperatureUnit,
      'hadithLang': this.hadithLang,
      'iqamaEnabled': this.iqamaEnabled,
      'randomHadithIntervalDisabling': this.randomHadithIntervalDisabling,
      'adhanVoice': this.adhanVoice,
      'adhanEnabledByPrayer': this.adhanEnabledByPrayer,
      'footer': this.footer,
      'iqamaMoreImportant': this.iqamaMoreImportant,
      'timeDisplayFormat': this.timeDisplayFormat,
      'backgroundType': this.backgroundType,
      'backgroundMotif': this.backgroundMotif,
      'iqamaFullScreenCountdown': this.iqamaFullScreenCountdown,
      'theme': this.theme,
    };
  }

  factory MosqueConfig.fromMap(Map<String, dynamic> map) {
    debugPrint(map.toString(), wrapWidth: 500);
    return MosqueConfig(
      duaAfterPrayerShowTimes: List.from(map["duaAfterPrayerShowTimes"]),
      hijriDateEnabled: map['hijriDateEnabled'],
      duaAfterAzanEnabled: map['duaAfterAzanEnabled'],
      duaAfterPrayerEnabled: map['duaAfterPrayerEnabled'],
      iqamaDisplayTime: map['iqamaDisplayTime'],
      iqamaBip: map['iqamaBip'],
      backgroundColor: map['backgroundColor'],
      jumuaDhikrReminderEnabled: map['jumuaDhikrReminderEnabled'],
      jumuaTimeout: map['jumuaTimeout'],
      randomHadithEnabled: map['randomHadithEnabled'],
      blackScreenWhenPraying: map['blackScreenWhenPraying'],
      wakeForFajrTime: map['wakeForFajrTime'],
      jumuaBlackScreenEnabled: map['jumuaBlackScreenEnabled'],
      temperatureEnabled: map['temperatureEnabled'],
      temperatureUnit: map['temperatureUnit'],
      hadithLang: map['hadithLang'],
      iqamaEnabled: map['iqamaEnabled'],
      randomHadithIntervalDisabling: map['randomHadithIntervalDisabling'],
      adhanVoice: map['adhanVoice'],
      adhanEnabledByPrayer: List.from(map['adhanEnabledByPrayer']),
      footer: map['footer'],
      iqamaMoreImportant: map['iqamaMoreImportant'] ?? false,
      timeDisplayFormat: map['timeDisplayFormat'],
      backgroundType: map['backgroundType'],
      backgroundMotif: map['backgroundMotif'],
      iqamaFullScreenCountdown: map['iqamaFullScreenCountdown'],
      theme: map['theme'],
    );
  }

//</editor-fold>
}
