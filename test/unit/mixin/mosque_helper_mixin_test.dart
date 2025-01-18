import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/AppDate.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mawaqit/src/services/mixins/mosque_helpers_mixins.dart';
import 'package:mawaqit/src/models/mosque.dart';
import 'package:mawaqit/src/models/times.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';

/// Mock classes
class MockMosque extends Mock implements Mosque {}

class MockTimes extends Mock implements Times {}

class MockMosqueConfig extends Mock implements MosqueConfig {}

/// A Test class that uses your [MosqueHelpersMixin]
class TestMosqueHelpers extends ChangeNotifier with MosqueHelpersMixin {
  @override
  Mosque? mosque;
  @override
  Times? times;
  @override
  MosqueConfig? mosqueConfig;

  /// Set or override online status
  @override
  bool isOnline = true;

  DateTime? _mockDateTime;

  @override
  DateTime mosqueDate() => _mockDateTime ?? DateTime.now();

  /// Helper to manually set the "current time" for test scenarios
  void setCurrentTime(DateTime dateTime) {
    _mockDateTime = dateTime;
    MockAppDateTime.setMockNow(dateTime);
  }
}

void main() {
  late TestMosqueHelpers mosqueHelpers;
  late MockTimes mockTimes;
  late MockMosqueConfig mockConfig;

  setUpAll(() {
    // Ensure mocktail knows about any custom matchers or signaled types.
    registerFallbackValue(DateTime(1970));
  });

  setUp(() {
    mosqueHelpers = TestMosqueHelpers();
    mockTimes = MockTimes();
    mockConfig = MockMosqueConfig();

    mosqueHelpers.times = mockTimes;
    mosqueHelpers.mosqueConfig = mockConfig;

    // Default times for dayTimesStrings
    when(() => mockTimes.dayTimesStrings(any())).thenReturn([
      '05:00', // Fajr
      '12:00', // Dhuhr
      '15:00', // Asr
      '18:00', // Maghrib
      '20:00', // Isha
    ]);

    // Default iqama times
    when(() => mockTimes.dayIqamaStrings(any())).thenReturn([
      '05:15', // Fajr
      '12:15', // Dhuhr
      '15:15', // Asr
      '18:15', // Maghrib
      '20:15', // Isha
    ]);

    // Default MosqueConfig
    when(() => mockConfig.duaAfterPrayerShowTimes)
        .thenReturn(['10', '10', '10', '10', '10']); // 10 minutes each prayer
    when(() => mockConfig.iqamaDisplayTime).thenReturn(10);
    when(() => mockConfig.jumuaTimeout).thenReturn(30);
    when(() => mockConfig.randomHadithIntervalDisabling).thenReturn('');
    when(() => mockConfig.adhanEnabledByPrayer).thenReturn(['1', '1', '1', '1', '1']);
    when(() => mockConfig.adhanVoice).thenReturn('some_adhan_voice.mp3');

    // Default Times
    when(() => mockTimes.hijriAdjustment).thenReturn(0);
    when(() => mockTimes.hijriDateForceTo30).thenReturn(false);
    when(() => mockTimes.jumua).thenReturn('13:30');
    when(() => mockTimes.jumuaAsDuhr).thenReturn(false);
    when(() => mockTimes.imsakNbMinBeforeFajr).thenReturn(0);

    // By default, isOnline is true
    mosqueHelpers.isOnline = true;
  });

  group('Basic Next Salah and Iqama calculations', () {
    test('nextSalahIndex() should return correct next prayer', () {
      mosqueHelpers.setCurrentTime(DateTime(2024, 1, 1, 11, 0)); // 11:00
      expect(mosqueHelpers.nextSalahIndex(), 1, reason: 'Should be Dhuhr next');

      mosqueHelpers.setCurrentTime(DateTime(2024, 1, 1, 12, 30)); // 12:30
      expect(mosqueHelpers.nextSalahIndex(), 2, reason: 'Should be Asr next');

      mosqueHelpers.setCurrentTime(DateTime(2024, 1, 1, 23, 35)); // 23:30
      expect(mosqueHelpers.nextSalahIndex(), 0, reason: 'Should roll over to next day Fajr');
    });

    test('nextIqamaIndex() should return correct next iqama', () {
      mosqueHelpers.setCurrentTime(DateTime(2024, 1, 1, 11, 0)); // 11:00
      expect(mosqueHelpers.nextIqamaIndex(), 1, reason: 'Next Iqama is Dhuhr at 12:15');

      mosqueHelpers.setCurrentTime(DateTime(2024, 1, 1, 23, 59)); // 23:59
      expect(mosqueHelpers.nextIqamaIndex(), 0, reason: 'Should be Fajr Iqama next day');
    });

    test('nextSalahAfter() gives the correct remaining Duration until next Salah', () {
      mosqueHelpers.setCurrentTime(DateTime(2024, 1, 1, 11, 0));
      expect(mosqueHelpers.nextSalahAfter(), const Duration(hours: 1), reason: '1 hour until 12:00');

      mosqueHelpers.setCurrentTime(DateTime(2024, 1, 1, 19, 30));
      // Next is Isha (20:00). So 30 minutes remain
      expect(mosqueHelpers.nextSalahAfter(), const Duration(minutes: 30), reason: '30 minutes to Isha');
    });

    test('nextIqamaaAfter() gives the correct remaining Duration until next Iqama', () {
      mosqueHelpers.setCurrentTime(DateTime(2024, 1, 1, 19, 30));
      // Next is Isha Iqama at 20:15 => 45 min
      expect(mosqueHelpers.nextIqamaaAfter(), const Duration(minutes: 45), reason: '45 minutes to Isha Iqama');

      mosqueHelpers.setCurrentTime(DateTime(2024, 1, 1, 12, 16));
      // Next is Asr Iqama at 15:15 => 2 hours and 59 minutes
      expect(mosqueHelpers.nextIqamaaAfter(), const Duration(hours: 2, minutes: 59));
    });
  });

  group('Imsak Handling', () {
    test('isImsakEnabled and imsak string should be correct when imsak is nonzero', () {
      when(() => mockTimes.imsakNbMinBeforeFajr).thenReturn(15);
      // Now Fajr is at 05:00, so Imsak = 04:45
      mosqueHelpers.setCurrentTime(DateTime(2024, 1, 1, 4, 0));
      expect(mosqueHelpers.isImsakEnabled, isTrue);
      expect(mosqueHelpers.imsak, '04:45');
    });

    test('isImsakEnabled should be false when 0', () {
      when(() => mockTimes.imsakNbMinBeforeFajr).thenReturn(0);
      expect(mosqueHelpers.isImsakEnabled, isFalse);
    });

    test('imsak should switch to tomorrow Fajr if current time has passed Fajr', () {
      // e.g., if now is 06:00, Fajr is 05:00 => show tomorrow Fajr minus imsak
      when(() => mockTimes.imsakNbMinBeforeFajr).thenReturn(10);
      mosqueHelpers.setCurrentTime(DateTime(2024, 1, 1, 6, 0)); // Past Fajr
      // Tomorrow Fajr => 05:00 => 05:00 - 10 min = 04:50
      expect(mosqueHelpers.imsak, '04:50');
    });
  });

  group('Shuruq Time', () {
    // test('isShurukTime is true when current time is after Fajr but before Shuruq', () {
    //   // Mock both dayTimesStrings and shuruq method
    //   when(() => mockTimes.dayTimesStrings(any(), salahOnly: false)).thenReturn([
    //     '05:00', // Fajr
    //     '06:30', // Shuruq
    //     '12:00',
    //     '15:00',
    //     '18:00',
    //     '20:00',
    //     '22:00',
    //   ]);
    //
    //   // Mock the shuruq method to return a specific DateTime
    //   when(() => mockTimes.shuruq(any())).thenReturn(
    //     DateTime(2024, 1, 1, 6, 30), // Shuruq at 06:30
    //   );
    //
    //   mosqueHelpers.setCurrentTime(DateTime(2024, 1, 1, 6, 0)); // 6:00
    //   expect(mosqueHelpers.isShurukTime, true);
    //
    //   mosqueHelpers.setCurrentTime(DateTime(2024, 1, 1, 7, 0));
    //   expect(mosqueHelpers.isShurukTime, false);
    // });

    test('getShurukTimeString() should return correct HH:mm format', () {
      // Mock the shuruq method directly since getShurukTimeString uses it
      when(() => mockTimes.shuruq(any())).thenReturn(
        DateTime(2024, 1, 1, 6, 30), // Shuruq at 06:30
      );

      expect(mosqueHelpers.getShurukTimeString(), '06:30');
    });
  });

  // group('Salah Workflow', () {
  //   test('salahWorkflow() is true 5 minutes before adhan up to the end of dua period', () {
  //     // Dhuhr at 12:00, Iqama at 12:15, and we have 10 minutes of Duaa
  //     // Workflow window:
  //     //   * 11:55 -> 12:00 (5 min before Dhuhr Adhan)
  //     //   * 12:00 -> 12:15 (Between adhan & iqama)
  //     //   * 12:15 -> 12:25 (During Salah + 10 min Duaa)
  //     // We'll test times around these intervals.
  //     mosqueHelpers.setCurrentTime(DateTime(2024, 1, 1, 11, 53));
  //     expect(mosqueHelpers.salahWorkflow(), false, reason: '6 min before Adhan => not in workflow');
  //
  //     mosqueHelpers.setCurrentTime(DateTime(2024, 1, 1, 11, 56));
  //     expect(mosqueHelpers.salahWorkflow(), true, reason: '5 min before Adhan => workflow started');
  //
  //     mosqueHelpers.setCurrentTime(DateTime(2024, 1, 1, 12, 10));
  //     expect(mosqueHelpers.salahWorkflow(), true, reason: 'Between Adhan & Iqama => workflow');
  //
  //     mosqueHelpers.setCurrentTime(DateTime(2024, 1, 1, 12, 15)); // Iqama
  //     expect(mosqueHelpers.salahWorkflow(), true, reason: 'During Iqama => still workflow');
  //
  //     mosqueHelpers.setCurrentTime(DateTime(2024, 1, 1, 12, 24));
  //     expect(mosqueHelpers.salahWorkflow(), true, reason: 'Still within 10 min after Iqama');
  //
  //     mosqueHelpers.setCurrentTime(DateTime(2024, 1, 1, 12, 26));
  //     expect(mosqueHelpers.salahWorkflow(), false, reason: 'After 10 min Duaa => workflow ends');
  //   });
  //
  //   test('salahWorkflow() with Isha after midnight', () {
  //     // Let's override dayTimesStrings to force Isha after midnight
  //     when(() => mockTimes.dayTimesStrings(any())).thenReturn([
  //       '05:00', // Fajr
  //       '12:00', // Dhuhr
  //       '15:00', // Asr
  //       '18:00', // Maghrib
  //       '00:30', // Isha next day
  //     ]);
  //     when(() => mockTimes.dayIqamaStrings(any())).thenReturn([
  //       '05:15',
  //       '12:15',
  //       '15:15',
  //       '18:15',
  //       '00:45', // Isha Iqama next day
  //     ]);
  //     // Suppose we have 10 minutes of Duaa after Isha
  //     when(() => mockConfig.duaAfterPrayerShowTimes).thenReturn(['10', '10', '10', '10', '10']);
  //
  //     // Test a time just before midnight
  //     mosqueHelpers.setCurrentTime(DateTime(2024, 1, 1, 23, 58));
  //     // Next adhan is at 00:30 => so 32 min away => not within 5 min => false
  //     expect(mosqueHelpers.salahWorkflow(), false);
  //
  //     // Test at 00:25 => 5 min before Adhan => becomes true
  //     mosqueHelpers.setCurrentTime(DateTime(2024, 1, 2, 0, 25));
  //     expect(mosqueHelpers.salahWorkflow(), true);
  //
  //     // Iqama is at 00:45 => plus 10 min => 00:55 => everything until 00:55 is in workflow
  //     mosqueHelpers.setCurrentTime(DateTime(2024, 1, 2, 0, 50));
  //     expect(mosqueHelpers.salahWorkflow(), true);
  //
  //     // 00:56 => outside that window after the azkar
  //     mosqueHelpers.setCurrentTime(DateTime(2024, 1, 2, 0, 58));
  //     expect(mosqueHelpers.salahWorkflow(), false);
  //   });
  // });

  group('Random Hadith disabling intervals', () {
    test('isDisableHadithBetweenSalah() returns false if no config is set', () {
      when(() => mockConfig.randomHadithIntervalDisabling).thenReturn('');
      expect(mosqueHelpers.isDisableHadithBetweenSalah(), false);
    });

    test('isDisableHadithBetweenSalah() returns false if parsing fails', () {
      when(() => mockConfig.randomHadithIntervalDisabling).thenReturn('abc-def');
      // We cannot parse start & end => returns null => false
      expect(mosqueHelpers.isDisableHadithBetweenSalah(), false);
    });

    test('isDisableHadithBetweenSalah() returns true if current prayer is between defined intervals', () {
      // Suppose we disable hadith between Asr (2) and Isha (4)
      when(() => mockConfig.randomHadithIntervalDisabling).thenReturn('2-4');

      // We'll tweak the times so that nextSalahIndex becomes 3 (Maghrib).
      when(() => mockTimes.dayTimesStrings(any())).thenReturn([
        '05:00', // Fajr
        '12:00', // Dhuhr
        '13:00', // Asr
        '14:30', // Maghrib
        '20:00', // Isha
      ]);
      // 14:00 => Next Salah is Maghrib at 14:30 => index 3 => so salahIndex = (3-1)%5 = 2 => Asr
      mosqueHelpers.setCurrentTime(DateTime(2024, 1, 1, 14, 0));

      expect(mosqueHelpers.isDisableHadithBetweenSalah(), true, reason: 'Because salahIndex=2 (Asr) is in [2..4)');
    });
  });

  group('Jumuaa Logic', () {
    test('jumuaaWorkflowTime() returns true for Friday near Jumuaa time', () {
      // By default, jumua is 13:30, jumuaTimeout=30 => from 13:30 until 14:00 + 5 min azkar => 14:05
      // Mosque is type "MOSQUE" => we simulate that
      final mockMosque = MockMosque();
      when(() => mockMosque.type).thenReturn('MOSQUE');
      mosqueHelpers.mosque = mockMosque;

      // For a Friday
      mosqueHelpers.setCurrentTime(DateTime(2024, 1, 5, 13, 25));
      expect(mosqueHelpers.jumuaaWorkflowTime(), false, reason: 'It starts at 13:30 exactly');

      mosqueHelpers.setCurrentTime(DateTime(2024, 1, 5, 13, 35));
      expect(mosqueHelpers.jumuaaWorkflowTime(), true, reason: 'During Jumuaa time');

      mosqueHelpers.setCurrentTime(DateTime(2024, 1, 5, 14, 0));
      expect(mosqueHelpers.jumuaaWorkflowTime(), true, reason: 'Still within 30 min + default kAzkarDuration');

      mosqueHelpers.setCurrentTime(DateTime(2024, 1, 5, 14, 10));
      expect(mosqueHelpers.jumuaaWorkflowTime(), false);
    });

    test('If Mosque type is not "MOSQUE", no jumuaaWorkflowTime()', () {
      final mockMosque = MockMosque();
      when(() => mockMosque.type).thenReturn('OTHER');
      mosqueHelpers.mosque = mockMosque;

      // Even on Friday 13:45 => should not be in Jumuaa
      mosqueHelpers.setCurrentTime(DateTime(2024, 1, 5, 13, 45));
      expect(mosqueHelpers.jumuaaWorkflowTime(), false);
    });
  });

  // group('Eid Logic', () {
  //   test('Eid is shown if date is in Eid range and aidPrayerTime is not null', () {
  //     when(() => mockTimes.aidPrayerTime).thenReturn('07:00');
  //     // We assume the hijri date is 1 Shawwal (month=9, day=1)
  //     // For demonstration, we skip actual hijri logic and assume it returns that day.
  //     expect(mosqueHelpers.showEid(0), true, reason: 'Because isEid range includes 1st day of 9th month');
  //     expect(mosqueHelpers.isEidFirstDay(0), true, reason: 'Because day=1 of month=9 => first day of Eid');
  //   });
  //
  //   test('Eid is not shown if Times has no aidPrayerTime', () {
  //     when(() => mockTimes.aidPrayerTime).thenReturn(null);
  //     expect(mosqueHelpers.showEid(0), false);
  //   });
  // });

  group('Corner Cases for durations', () {
    test('currentSalahDuration returns zero if MosqueConfig is null', () {
      mosqueHelpers.mosqueConfig = null;
      expect(mosqueHelpers.currentSalahDuration, Duration.zero);
    });

    test('Extremely large durations remain valid', () {
      when(() => mockConfig.duaAfterPrayerShowTimes).thenReturn(['9999', '10', '10', '10', '10']);
      // Force a scenario so nextSalahIndex => 1 => => salahIndex=0 => we get '9999'
      // We do this by ensuring the current time is after Fajr but before Dhuhr, so next= Dhuhr => index=1
      // Then salahIndex = (1 - 1)%5 => 0 => Fajr => '9999' minutes
      mosqueHelpers.setCurrentTime(DateTime(2024, 1, 1, 6, 0));
      expect(mosqueHelpers.salahIndex, 0, reason: 'So we read [0] from duaAfterPrayerShowTimes => 9999');
      expect(mosqueHelpers.currentSalahDuration, Duration(minutes: 9999));
    });
  });

  // ------------------------------------------------------------------------
  //  NEW GROUP: Midnight Cases (Isha & Maghrib)
  // ------------------------------------------------------------------------
  group('Midnight Cases (Isha & Maghrib)', () {
    //
    // CASE 1: Isha after midnight
    //
    setUp(() {
      // Override the default times so that "Isha" is after midnight (01:00).
      when(() => mockTimes.dayTimesStrings(any())).thenReturn([
        '05:00', // Fajr
        '12:00', // Dhuhr
        '15:00', // Asr
        '18:00', // Maghrib
        '01:00', // Isha (next day, crossing midnight)
      ]);
    });

    test('If current time is 00:45 and Isha is at 01:00, next prayer should be Isha, NOT Fajr', () {
      mosqueHelpers.setCurrentTime(DateTime(2024, 1, 2, 0, 45));
      // nextSalahIndex => 4 (Isha)
      expect(mosqueHelpers.nextSalahIndex(), 4, reason: 'Should indicate Isha is the next prayer, not Fajr');
      // 15 minutes remaining
      expect(mosqueHelpers.nextSalahAfter(), const Duration(minutes: 15), reason: '15 min until Isha');
    });

    test('If current time is 01:05 (just after 01:00 Isha), next prayer is Fajr', () {
      mosqueHelpers.setCurrentTime(DateTime(2024, 1, 2, 1, 5));
      // We are already past Isha => next is Fajr => index=0
      expect(mosqueHelpers.nextSalahIndex(), 0, reason: 'Now we’ve passed 01:00 Isha, so next is Fajr at 05:00');
      expect(mosqueHelpers.nextSalahAfter(), const Duration(hours: 3, minutes: 55),
          reason: '3h55m until Fajr at 05:00');
    });

    // test('If current time is exactly 01:00, next prayer is likely Isha (depending on your business logic)', () {
    //   mosqueHelpers.setCurrentTime(DateTime(2024, 1, 2, 1, 0));
    //   // Some apps keep the current prayer as "Isha" if we are exactly at 01:00
    //   expect(mosqueHelpers.nextSalahIndex(), 4,
    //       reason: 'At 01:00, we typically still regard Isha as the current/next prayer');
    //   expect(mosqueHelpers.nextSalahAfter(), Duration.zero, reason: 'No time remains until Isha');
    // });

    //
    // CASE 2: Maghrib after midnight
    //
    test('Maghrib after midnight scenario (rare/unusual but tested)', () {
      // Overriding dayTimesStrings again but now specifically for Maghrib
      when(() => mockTimes.dayTimesStrings(any())).thenReturn([
        '05:00', // Fajr
        '12:00', // Dhuhr
        '15:00', // Asr
        '00:10', // Maghrib (crossing midnight)
        '01:00', // Isha
      ]);

      // Time is 23:55 (previous day)
      mosqueHelpers.setCurrentTime(DateTime(2024, 1, 1, 23, 55));
      // Next prayer => Maghrib at 00:10, index=3
      expect(mosqueHelpers.nextSalahIndex(), 3, reason: 'Maghrib is still upcoming at 00:10');
      // 15 min away from 23:55 to 00:10
      expect(mosqueHelpers.nextSalahAfter(), const Duration(minutes: 15), reason: '15 min until Maghrib');

      // If we move time to 00:12 => we’re past Maghrib => next is Isha
      mosqueHelpers.setCurrentTime(DateTime(2024, 1, 2, 0, 12));
      expect(mosqueHelpers.nextSalahIndex(), 4, reason: 'We passed Maghrib => next is Isha');
    });
  });
}
