import 'dart:developer';

import 'AppDate.dart';

class TimeHelper {
  /// [isBetweenStartAndEnd] checks if the current time is between the provided start and end time.
  /// case 1: if both start and end are null, return false
  /// case 2: if start is null, check if now is before end
  /// case 3: if end is null, check if now is after start
  /// case 4: if both start and end are not null, check if now is between start and end
  static bool isBetweenStartAndEnd(DateTime? start, DateTime? end, [String tag = '']) {
    final now = AppDateTime.now();
    log('$tag: _isBetweenStartAndEnd - now: $now, start: $start, end: $end');
    // If both start and end are null, return false
    if (start == null && end == null) {
      log('$tag: _isBetweenStartAndEnd - both start and end are null');
      return true;
    }

    // If start is null, check if now is before end
    if (start == null) {
      log('$tag: AnnouncementWorkflowNotifier: _isBetweenStartAndEnd - start is null');
      return now.isBefore(end!) || now.isAtSameMomentAs(end!);
    }

    // If end is null, check if now is after start
    if (end == null) {
      log('$tag: AnnouncementWorkflowNotifier: _isBetweenStartAndEnd - end is null');
      return now.isAfter(start) || now.isAtSameMomentAs(start);
    }
    log('$tag: AnnouncementWorkflowNotifier: _isBetweenStartAndEnd -  both start and end are not null');
    // If both start and end are not null, check if now is between start and end
    return now.isAfter(start) && now.isBefore(end) || now.isAtSameMomentAs(start) || now.isAtSameMomentAs(end);
  }
}
