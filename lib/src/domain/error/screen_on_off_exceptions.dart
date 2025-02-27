abstract class SchedulingException implements Exception {
  final String message;
  final String errorCode;

  SchedulingException(this.message, this.errorCode);

  @override
  String toString() => 'Error ($errorCode): $message';
}

class ScheduleToggleScreenException extends SchedulingException {
  ScheduleToggleScreenException(String message)
      : super('Error occurred while scheduling toggle screen: $message', 'SCHEDULE_TOGGLE_SCREEN_ERROR');
}

class RestoreScheduledTimersException extends SchedulingException {
  RestoreScheduledTimersException(String message)
      : super('Error occurred while restoring scheduled timers: $message', 'RESTORE_SCHEDULED_TIMERS_ERROR');
}

class SchedulePrayerTimeException extends SchedulingException {
  SchedulePrayerTimeException(String message)
      : super('Error occurred while scheduling prayer time: $message', 'SCHEDULE_PRAYER_TIME_ERROR');
}

class LoadScheduledTimersException extends SchedulingException {
  LoadScheduledTimersException(String message)
      : super('Error occurred while loading scheduled timers: $message', 'LOAD_SCHEDULED_TIMERS_ERROR');
}

class DailyReschedulingException extends SchedulingException {
  DailyReschedulingException(String message)
      : super('Error occurred while handling daily rescheduling: $message', 'DAILY_RESCHEDULING_ERROR');
}

class TimerExecutionException extends SchedulingException {
  TimerExecutionException(String message)
      : super('Error occurred while executing timer action: $message', 'TIMER_EXECUTION_ERROR');
}

class UnknownSchedulingException extends SchedulingException {
  UnknownSchedulingException(String message) : super('Unknown scheduling error: $message', 'UNKNOWN_SCHEDULING_ERROR');
}
