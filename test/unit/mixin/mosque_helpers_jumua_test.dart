import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mawaqit/src/models/times.dart';
import 'package:mawaqit/src/models/mosque.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';
import 'package:mawaqit/src/services/mixins/mosque_helpers_mixins.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';

// Create mocks
class MockTimes extends Mock implements Times {}

class MockMosque extends Mock implements Mosque {}

class MockMosqueConfig extends Mock implements MosqueConfig {}

// Test implementation of MosqueHelpersMixin
class TestMosqueHelpersMixin extends ChangeNotifier with MosqueHelpersMixin {
  @override
  Mosque? mosque;

  @override
  Times? times;

  @override
  MosqueConfig? mosqueConfig;

  @override
  bool get isOnline => true;

  // Override mosque date for test purposes
  DateTime _testDate = DateTime(2023, 6, 30, 12, 0); // Friday at noon

  @override
  DateTime mosqueDate() => _testDate;

  void setMosqueDate(DateTime date) {
    _testDate = date;
    notifyListeners();
  }

  // Override timesOfDay for test purposes
  List<String> _testTimesOfDay = ['05:00', '12:30', '16:00', '19:00', '21:00'];

  @override
  List<String> timesOfDay(DateTime date, {bool forceActualDuhr = false}) {
    // If forceActualDuhr is true, return the original test times
    if (forceActualDuhr) {
      return _testTimesOfDay;
    }

    // Otherwise, handle the jumuaAsDuhr case manually for testing
    if (date.weekday == DateTime.friday && typeIsMosque && times?.jumua != null && times?.jumuaAsDuhr == false) {
      var result = List<String>.from(_testTimesOfDay);
      result[1] = times!.jumua!;
      return result;
    }

    return _testTimesOfDay;
  }

  void setTestTimesOfDay(List<String> times) {
    _testTimesOfDay = times;
    notifyListeners();
  }

  @override
  bool get typeIsMosque => true;

  // Override nextFridayDate to use our test date
  @override
  DateTime nextFridayDate([DateTime? now]) {
    now ??= _testDate;
    return now.add(Duration(days: (7 - now.weekday + DateTime.friday) % 7));
  }
}

void main() {
  late TestMosqueHelpersMixin helper;
  late MockTimes mockTimes;
  late MockMosque mockMosque;
  late MockMosqueConfig mockMosqueConfig;

  setUp(() {
    mockTimes = MockTimes();
    mockMosque = MockMosque();
    mockMosqueConfig = MockMosqueConfig();

    helper = TestMosqueHelpersMixin()
      ..mosque = mockMosque
      ..times = mockTimes
      ..mosqueConfig = mockMosqueConfig;

    // Default mosque config setup
    when(() => mockMosqueConfig.jumuaTimeout).thenReturn(30);

    // Default times setup - Friday and not jumuaAsDuhr
    when(() => mockTimes.jumua).thenReturn('13:00');
    when(() => mockTimes.jumua2).thenReturn(null);
    when(() => mockTimes.jumua3).thenReturn(null);
    when(() => mockTimes.jumuaAsDuhr).thenReturn(false);

    // Setup test timesOfDay
    helper.setTestTimesOfDay(['05:00', '12:30', '16:00', '19:00', '21:00']);

    // Set default date to Friday at noon
    helper.setMosqueDate(DateTime(2023, 6, 30, 12, 0)); // Friday at noon
  });

  group('getOrderedJumuaTimes', () {
    test('should return a single jumua time when only jumua is configured', () {
      // Setup
      when(() => mockTimes.jumua).thenReturn('13:00');
      when(() => mockTimes.jumua2).thenReturn(null);
      when(() => mockTimes.jumua3).thenReturn(null);
      when(() => mockTimes.jumuaAsDuhr).thenReturn(false);

      // Test
      final result = helper.getOrderedJumuaTimes();

      // Verify
      expect(result, ['13:00']);
    });

    test('should return multiple jumua times when all are configured', () {
      // Setup
      when(() => mockTimes.jumua).thenReturn('13:00');
      when(() => mockTimes.jumua2).thenReturn('14:00');
      when(() => mockTimes.jumua3).thenReturn('15:00');
      when(() => mockTimes.jumuaAsDuhr).thenReturn(false);

      // Test
      final result = helper.getOrderedJumuaTimes();

      // Verify
      expect(result, ['13:00', '14:00', '15:00']);
    });

    test('should handle jumua2 without jumua1', () {
      // Setup
      when(() => mockTimes.jumua).thenReturn(null);
      when(() => mockTimes.jumua2).thenReturn('14:00');
      when(() => mockTimes.jumua3).thenReturn(null);
      when(() => mockTimes.jumuaAsDuhr).thenReturn(false);

      // Test
      final result = helper.getOrderedJumuaTimes();

      // Verify
      expect(result, ['14:00']);
    });

    test('should return duhr time when jumuaAsDuhr is true', () {
      // Setup
      when(() => mockTimes.jumuaAsDuhr).thenReturn(true);
      helper.setTestTimesOfDay(['05:00', '12:30', '16:00', '19:00', '21:00']);

      // Test
      final result = helper.getOrderedJumuaTimes();

      // Verify
      expect(result, ['12:30']);
    });

    test('should return duhr time and additional jumua times when jumuaAsDuhr is true and jumua2/3 are configured', () {
      // Setup
      when(() => mockTimes.jumuaAsDuhr).thenReturn(true);
      when(() => mockTimes.jumua2).thenReturn('14:00');
      when(() => mockTimes.jumua3).thenReturn('15:00');

      // Test
      final result = helper.getOrderedJumuaTimes();

      // Verify
      expect(result, ['12:30', '14:00', '15:00']);
    });

    test('should return duhr time and when jumuaAsDuhr is true and jumua1/2/3 are configured', () {
      // Setup
      when(() => mockTimes.jumuaAsDuhr).thenReturn(true);
      when(() => mockTimes.jumua).thenReturn('12:10');
      when(() => mockTimes.jumua2).thenReturn('14:00');
      when(() => mockTimes.jumua3).thenReturn('15:00');

      helper.setTestTimesOfDay(['05:00', '12:30', '16:00', '19:00', '21:00']);

      // Test
      final result = helper.getOrderedJumuaTimes();

      // Verify
      expect(result, ['12:30', '14:00', '15:00']);
    });

    test('should return empty list when no jumua times are configured and jumuaAsDuhr is false', () {
      // Setup
      when(() => mockTimes.jumua).thenReturn(null);
      when(() => mockTimes.jumua2).thenReturn(null);
      when(() => mockTimes.jumua3).thenReturn(null);
      when(() => mockTimes.jumuaAsDuhr).thenReturn(false);

      // Test
      final result = helper.getOrderedJumuaTimes();

      // Verify
      expect(result, []);
    });
  });

  group('activeJumuaaDate', () {
    test('should return date with first jumua time on Friday', () {
      // Setup
      when(() => mockTimes.jumua).thenReturn('13:00');
      when(() => mockTimes.jumuaAsDuhr).thenReturn(false);
      final expectedDate = DateTime(2023, 6, 30, 13, 0); // Friday at 13:00

      // Test
      final result = helper.activeJumuaaDate();

      // Verify
      expect(result.hour, expectedDate.hour);
      expect(result.minute, expectedDate.minute);
      expect(result.weekday, DateTime.friday);
    });

    test('should return date with duhr time when jumuaAsDuhr is true', () {
      // Setup
      when(() => mockTimes.jumuaAsDuhr).thenReturn(true);
      helper.setTestTimesOfDay(['05:00', '12:30', '16:00', '19:00', '21:00']);
      final expectedDate = DateTime(2023, 6, 30, 12, 30); // Friday at 12:30 (duhr time)

      // Test
      final result = helper.activeJumuaaDate();

      // Verify
      expect(result.hour, expectedDate.hour);
      expect(result.minute, expectedDate.minute);
      expect(result.weekday, DateTime.friday);
    });

    test('should return next Friday date when no jumua times are configured', () {
      // Setup - Set current date to Thursday
      helper.setMosqueDate(DateTime(2023, 6, 29, 12, 0)); // Thursday at noon
      when(() => mockTimes.jumua).thenReturn(null);
      when(() => mockTimes.jumua2).thenReturn(null);
      when(() => mockTimes.jumua3).thenReturn(null);
      when(() => mockTimes.jumuaAsDuhr).thenReturn(false);

      // Test
      final result = helper.activeJumuaaDate();

      // Verify
      expect(result.weekday, DateTime.friday);
      expect(result.day, 30); // Next Friday
    });

    test('should handle non-Friday date correctly', () {
      // Setup - Set current date to Wednesday
      helper.setMosqueDate(DateTime(2023, 6, 28, 12, 0)); // Wednesday at noon
      when(() => mockTimes.jumua).thenReturn('13:00');

      // Test
      final result = helper.activeJumuaaDate();

      // Verify - Should return Friday with jumua time
      expect(result.weekday, DateTime.friday);
      expect(result.hour, 13);
      expect(result.minute, 0);
    });
  });

  group('jumuaaWorkflowTime', () {
    test('should return false when current day is not Friday', () {
      // Setup - Set current date to Thursday
      helper.setMosqueDate(DateTime(2023, 6, 29, 12, 0)); // Thursday at noon

      // Test
      final result = helper.jumuaaWorkflowTime();

      // Verify
      expect(result, false);
    });

    test('should return false when current time is before jumua time', () {
      // Setup
      when(() => mockTimes.jumua).thenReturn('13:00');
      helper.setMosqueDate(DateTime(2023, 6, 30, 12, 0)); // Friday at noon (before jumua)

      // Test
      final result = helper.jumuaaWorkflowTime();

      // Verify
      expect(result, false);
    });

    test('should return true when current time is during jumua workflow time', () {
      // Setup
      when(() => mockTimes.jumua).thenReturn('13:00');
      when(() => mockMosqueConfig.jumuaTimeout).thenReturn(30);
      helper.setMosqueDate(DateTime(2023, 6, 30, 13, 10)); // Friday during jumua time

      // Test
      final result = helper.jumuaaWorkflowTime();

      // Verify
      expect(result, true);
    });

    test('should return false when current time is after jumua workflow time ends', () {
      // Setup
      when(() => mockTimes.jumua).thenReturn('13:00');
      when(() => mockMosqueConfig.jumuaTimeout).thenReturn(30);
      helper.setMosqueDate(DateTime(2023, 6, 30, 14, 0)); // Friday after jumua workflow ends

      // Test
      final result = helper.jumuaaWorkflowTime();

      // Verify
      expect(result, false);
    });

    test('should handle jumuaAsDuhr case correctly', () {
      // Setup
      when(() => mockTimes.jumuaAsDuhr).thenReturn(true);
      helper.setTestTimesOfDay(['05:00', '12:30', '16:00', '19:00', '21:00']);
      helper.setMosqueDate(DateTime(2023, 6, 30, 12, 40)); // Friday during duhr time

      // Test
      final result = helper.jumuaaWorkflowTime();

      // Verify
      expect(result, true);
    });
  });

  group('nextFridayDate', () {
    test('should return the current date if it is Friday', () {
      // Setup
      final friday = DateTime(2023, 6, 30); // A Friday
      helper.setMosqueDate(friday);

      // Test
      final result = helper.nextFridayDate();

      // Verify
      expect(result.year, friday.year);
      expect(result.month, friday.month);
      expect(result.day, friday.day);
    });

    test('should return the next Friday if current date is not Friday', () {
      // Test for each day of the week
      final days = [
        // Current day, expected next Friday
        [DateTime(2023, 6, 24), DateTime(2023, 6, 30)], // Saturday -> Next Friday
        [DateTime(2023, 6, 25), DateTime(2023, 6, 30)], // Sunday -> Next Friday
        [DateTime(2023, 6, 26), DateTime(2023, 6, 30)], // Monday -> Next Friday
        [DateTime(2023, 6, 27), DateTime(2023, 6, 30)], // Tuesday -> Next Friday
        [DateTime(2023, 6, 28), DateTime(2023, 6, 30)], // Wednesday -> Next Friday
        [DateTime(2023, 6, 29), DateTime(2023, 6, 30)], // Thursday -> Next Friday
        [DateTime(2023, 6, 30), DateTime(2023, 6, 30)], // Friday -> Same Friday
      ];

      for (final test in days) {
        // Setup
        helper.setMosqueDate(test[0] as DateTime);

        // Test
        final result = helper.nextFridayDate();
        final expected = test[1] as DateTime;

        // Verify
        expect(result.year, expected.year);
        expect(result.month, expected.month);
        expect(result.day, expected.day);
      }
    });
  });

  group('Integration tests', () {
    test('should handle a complete Friday workflow correctly', () {
      // Setup - Start with Thursday
      helper.setMosqueDate(DateTime(2023, 6, 29, 12, 0)); // Thursday at noon
      when(() => mockTimes.jumua).thenReturn('13:00');
      when(() => mockTimes.jumuaAsDuhr).thenReturn(false);

      // Test - Not Friday yet
      expect(helper.jumuaaWorkflowTime(), false);

      // Move to Friday morning
      helper.setMosqueDate(DateTime(2023, 6, 30, 10, 0)); // Friday morning at time 10:00

      // Test - Friday but before jumua
      expect(helper.getOrderedJumuaTimes(), ['13:00']);
      expect(helper.jumuaaWorkflowTime(), false);

      // Move to jumua time
      helper.setMosqueDate(DateTime(2023, 6, 30, 13, 10)); // During jumua at time 13:00

      // Test - During jumua workflow
      expect(helper.jumuaaWorkflowTime(), true);

      // Move after jumua
      helper.setMosqueDate(DateTime(2023, 6, 30, 14, 0)); // After jumua at time 14:00

      // Test - After jumua workflow
      expect(helper.jumuaaWorkflowTime(), false);
    });

    test('should handle multiple jumua times correctly', () {
      // Setup
      when(() => mockTimes.jumua).thenReturn('13:00');
      when(() => mockTimes.jumua2).thenReturn('14:30');
      when(() => mockTimes.jumua3).thenReturn('16:00');

      // Test - Get ordered times
      expect(helper.getOrderedJumuaTimes(), ['13:00', '14:30', '16:00']);

      // Test - Active jumua date should use first time
      final activeDate = helper.activeJumuaaDate();
      expect(activeDate.hour, 13);
      expect(activeDate.minute, 0);

      // Test - Workflow should follow first jumua time
      helper.setMosqueDate(DateTime(2023, 6, 30, 13, 10)); // During first jumua
      expect(helper.jumuaaWorkflowTime(), true);

      helper.setMosqueDate(DateTime(2023, 6, 30, 14, 40)); // During second jumua time
      // This should be false as workflow only follows first jumua
      expect(helper.jumuaaWorkflowTime(), false);
    });

    test('should handle jumuaAsDuhr edge cases', () {
      // Setup
      when(() => mockTimes.jumuaAsDuhr).thenReturn(true);
      when(() => mockTimes.jumua).thenReturn(null); // No explicit jumua time
      helper.setTestTimesOfDay(['05:00', '12:30', '16:00', '19:00', '21:00']);

      // Test - Get ordered times should return duhr time
      expect(helper.getOrderedJumuaTimes(), ['12:30']);

      // Test - Active jumua date should use duhr time
      final activeDate = helper.activeJumuaaDate();
      expect(activeDate.hour, 12);
      expect(activeDate.minute, 30);

      // Test - Workflow should follow duhr time
      helper.setMosqueDate(DateTime(2023, 6, 30, 12, 40)); // During duhr
      expect(helper.jumuaaWorkflowTime(), true);
    });
  });
}
