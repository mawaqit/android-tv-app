import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mawaqit/src/helpers/AppDate.dart';

extension StringTimeUtils on String {
  /// convert xx:xx to today date
  DateTime toTodayDate([DateTime? today, DateTime? tryOffset]) {
    today ??= AppDateTime.now();

    try {
      return DateFormat('HH:mm').parse(this).copyWith(year: today.year, month: today.month, day: today.day);
    } on FormatException catch (e) {
      if (tryOffset != null) {
        final value = int.tryParse(this);
        if (value != null) return tryOffset.add(Duration(minutes: value));
      }

      rethrow;
    }
  }

  /// expect value of xx:xx with
  /// incase of [tryOffset] handle also the relative timing in minutes like +5
  TimeOfDay? toTimeOfDay({DateTime? tryOffset, minimumMinutes = 0}) {
    try {
      final String hour = this.split(":").first;
      final String minute = this.replaceFirst(hour, "").replaceFirst(":", "");

      // final date = DateFormat('HH:mm').parse(trim());

      return TimeOfDay(hour: int.parse(hour), minute: int.parse(minute));
    } on FormatException catch (e, stack) {
      if (tryOffset != null) {
        final value = int.tryParse(this);
        if (value != null)
          return TimeOfDay.fromDateTime(
            tryOffset.add(
              Duration(
                minutes: max(
                  value,
                  minimumMinutes,
                ),
              ),
            ),
          );
      }

      // debugPrintStack(label: 'Failed to format $this $tryOffset', stackTrace: stack);
    }

    return null;
  }

  /// expect value of +2 with date
  TimeOfDay? toTimeOffset(String time) {
    try {
      return TimeOfDay.fromDateTime(time.toTimeOfDay()!.toDate().add(Duration(minutes: int.parse(this))));
    } on FormatException catch (e) {}

    return null;
  }
}

extension TimeUtils on TimeOfDay {
  int get inMinutes => hour * 60 + minute;

  bool isAfter(TimeOfDay other) {
    if (this.hour > other.hour) return true;

    if (this.hour < other.hour) return false;

    return this.minute > other.minute;
  }

  bool isBefore(TimeOfDay other) {
    if (this.hour < other.hour) return true;

    if (this.hour > other.hour) return false;

    return this.minute < other.minute;
  }

  DateTime toDate([DateTime? date]) {
    date ??= DateTime.now();

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  /// use cases
  /// 05:44 between 05:00 to 06:00  -> true
  /// 05:44 between 08:00 to 06:00  -> true
  /// 05:44 between 08:00 to 06:00  -> true  (in the next day)
  /// 05:44 between 05:44 to any  -> true
  bool between(TimeOfDay first, TimeOfDay second) {
    if (this == first || this == second) return true;

    if (second.isAfter(first)) {
      bool between = (isAfter(first) && isBefore(second));

      return between;
    } else {
      bool between = isAfter(first) || isBefore(second);

      return between;
    }
  }
}

String timeTwoDigit({required int seconds, required int minutes}) {
  String twoDigitSecond = "${seconds.toString().padLeft(2, "0")}";
  String twoDigitMinute = "${minutes.toString().padLeft(2, "0")}";
  return "$twoDigitMinute:$twoDigitSecond";
}
