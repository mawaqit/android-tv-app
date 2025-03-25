import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';
import 'package:mawaqit/src/services/mixins/audio_mixin.dart';

// Class that implements AudioMixin for testing
class TestAudioMixin extends ChangeNotifier with AudioMixin {
  @override
  MosqueConfig? mosqueConfig;

  bool _typeIsMosqueValue = false;

  @override
  bool get typeIsMosque => _typeIsMosqueValue;

  // Setter for testing
  set typeIsMosque(bool value) {
    _typeIsMosqueValue = value;
  }
}

// Simple implementation of MosqueConfig for testing
class TestMosqueConfig implements MosqueConfig {
  @override
  final String? adhanVoice;

  @override
  final int? adhanDuration;

  // Implement other required fields with default values
  @override
  final List<String> duaAfterPrayerShowTimes;

  @override
  final bool? hijriDateEnabled;

  @override
  final bool? duaAfterAzanEnabled;

  @override
  final bool? duaAfterPrayerEnabled;

  @override
  final int? iqamaDisplayTime;

  @override
  final bool iqamaBip;

  @override
  final bool showCityInTitle;

  @override
  final bool showLogo;

  @override
  final String? backgroundColor;

  @override
  final bool? jumuaDhikrReminderEnabled;

  @override
  final int? jumuaTimeout;

  @override
  final bool randomHadithEnabled;

  @override
  final bool? blackScreenWhenPraying;

  @override
  final int? wakeForFajrTime;

  @override
  final bool? jumuaBlackScreenEnabled;

  @override
  final bool? temperatureEnabled;

  @override
  final String? temperatureUnit;

  @override
  final String? hadithLang;

  @override
  final bool? iqamaEnabled;

  @override
  final String? randomHadithIntervalDisabling;

  @override
  final List<String>? adhanEnabledByPrayer;

  @override
  final bool? footer;

  @override
  final bool? iqamaMoreImportant;

  @override
  final bool? showPrayerTimesOnMessageScreen;

  @override
  final String? timeDisplayFormat;

  @override
  final String? backgroundType;

  @override
  final String? backgroundMotif;

  @override
  final bool? iqamaFullScreenCountdown;

  @override
  final String? theme;

  // Constructor with named parameters
  TestMosqueConfig({
    this.adhanVoice,
    this.adhanDuration,
    this.duaAfterPrayerShowTimes = const ['10', '10', '10', '10', '10'],
    this.hijriDateEnabled = true,
    this.duaAfterAzanEnabled = true,
    this.duaAfterPrayerEnabled = true,
    this.iqamaDisplayTime = 10,
    this.iqamaBip = false,
    this.showCityInTitle = true,
    this.showLogo = true,
    this.backgroundColor = '#000000',
    this.jumuaDhikrReminderEnabled = true,
    this.jumuaTimeout = 30,
    this.randomHadithEnabled = true,
    this.blackScreenWhenPraying = false,
    this.wakeForFajrTime = 0,
    this.jumuaBlackScreenEnabled = false,
    this.temperatureEnabled = true,
    this.temperatureUnit = 'C',
    this.hadithLang = 'en',
    this.iqamaEnabled = true,
    this.randomHadithIntervalDisabling = '',
    this.adhanEnabledByPrayer = const ['1', '1', '1', '1', '1'],
    this.footer = true,
    this.iqamaMoreImportant = false,
    this.showPrayerTimesOnMessageScreen = true,
    this.timeDisplayFormat = '24h',
    this.backgroundType = 'color',
    this.backgroundMotif = '1',
    this.iqamaFullScreenCountdown = true,
    this.theme = 'light',
  });

  @override
  String get motifUrl => 'https://mawaqit.net/prayer-times/img/background/${backgroundMotif ?? 5}.jpg';

  // For simplicity, these methods aren't fully implemented in the test class
  @override
  MosqueConfig copyWith(
      {Object? duaAfterPrayerShowTimes,
      Object? hijriDateEnabled,
      Object? duaAfterAzanEnabled,
      Object? duaAfterPrayerEnabled,
      Object? iqamaDisplayTime,
      Object? iqamaBip,
      Object? showLogo,
      Object? showCityInTitle,
      Object? backgroundColor,
      Object? jumuaDhikrReminderEnabled,
      Object? jumuaTimeout,
      Object? randomHadithEnabled,
      Object? blackScreenWhenPraying,
      Object? wakeForFajrTime,
      Object? jumuaBlackScreenEnabled,
      Object? temperatureEnabled,
      Object? temperatureUnit,
      Object? hadithLang,
      Object? iqamaEnabled,
      Object? randomHadithIntervalDisabling,
      Object? adhanVoice,
      Object? footer,
      Object? iqamaMoreImportant,
      Object? timeDisplayFormat,
      Object? backgroundType,
      Object? backgroundMotif,
      Object? iqamaFullScreenCountdown,
      Object? showPrayerTimesOnMessageScreen,
      Object? theme,
      Object? adhanDuration}) {
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toMap() {
    throw UnimplementedError();
  }
}

void main() {
  group('AudioMixin Tests', () {
    late TestAudioMixin audioMixin;

    setUp(() {
      audioMixin = TestAudioMixin();
    });

    test('getAdhanDuration returns mosqueConfig.adhanDuration when typeIsMosque is true', () {
      // Arrange
      audioMixin.mosqueConfig = TestMosqueConfig(adhanVoice: 'adhan-afassy', adhanDuration: 120);
      audioMixin.typeIsMosque = true;

      // Act
      final duration = audioMixin.getAdhanDuration(false);

      // Assert
      expect(duration, equals(Duration(seconds: 120)));
    });

    test('getAdhanDuration returns predefined duration for home type when typeIsMosque is false', () {
      // Arrange
      audioMixin.mosqueConfig = TestMosqueConfig(adhanVoice: 'adhan-afassy', adhanDuration: 120);
      audioMixin.typeIsMosque = false;

      // Act
      final duration = audioMixin.getAdhanDuration(false);

      // Assert
      expect(duration, equals(Duration(seconds: 154 + 5))); // Should match predefined value
    });

    test('getAdhanDuration returns fajr-specific duration for fajr prayer in home mode', () {
      // Arrange
      audioMixin.mosqueConfig = TestMosqueConfig(adhanVoice: 'adhan-afassy', adhanDuration: 120);
      audioMixin.typeIsMosque = false;

      // Act
      final duration = audioMixin.getAdhanDuration(true); // isFajrPray = true

      // Assert
      expect(duration, equals(Duration(seconds: 182 + 5))); // Should match fajr-specific value
    });

    test('getAdhanDuration handles different adhan voices correctly', () {
      // Arrange
      audioMixin.mosqueConfig = TestMosqueConfig(adhanVoice: 'adhan-egypt', adhanDuration: 120);
      audioMixin.typeIsMosque = false;

      // Act
      final duration = audioMixin.getAdhanDuration(false);

      // Assert
      expect(duration, equals(Duration(seconds: 221 + 5))); // Should match egypt adhan
    });

    test('getAdhanDuration uses default duration when adhan voice is not recognized', () {
      // Arrange
      audioMixin.mosqueConfig = TestMosqueConfig(adhanVoice: 'unknown-adhan', adhanDuration: 120);
      audioMixin.typeIsMosque = false;

      // Act
      final duration = audioMixin.getAdhanDuration(false);

      // Assert
      // Should use the mosque config duration as fallback
      expect(duration, equals(Duration(seconds: 120)));
    });

    test('getAdhanDuration uses fallback 180 seconds when config has no duration', () {
      // Arrange
      audioMixin.mosqueConfig = TestMosqueConfig(adhanVoice: 'adhan-afassy', adhanDuration: null);
      audioMixin.typeIsMosque = false;

      // Act
      final duration = audioMixin.getAdhanDuration(false);

      // Assert
      // For adhan-afassy, it should still use the predefined duration
      expect(duration, equals(Duration(seconds: 154 + 5)));
    });

    test('getAdhanDuration handles null adhanVoice', () {
      // Arrange
      audioMixin.mosqueConfig = TestMosqueConfig(adhanVoice: null, adhanDuration: 120);
      audioMixin.typeIsMosque = false;

      // Act
      final duration = audioMixin.getAdhanDuration(false);

      // Assert
      // Should use the default duration set in the method
      expect(duration, equals(Duration(seconds: 120)));
    });

    test('getAdhanDuration with null mosqueConfig returns default duration', () {
      // Arrange
      audioMixin.mosqueConfig = null;
      audioMixin.typeIsMosque = false;

      // Act
      final duration = audioMixin.getAdhanDuration(false);

      // Assert
      // Should return the default duration for null config
      expect(duration, equals(Duration(seconds: 150)));
    });
  });
}
