import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mawaqit/src/helpers/time_utils.dart';
import 'package:mawaqit/src/widgets/TimePeriodWidget.dart';

/// this widget should be used the show times in the app
class TimeWidget extends StatelessWidget {
  /// show time for a specific time using [TimeOfDay]
  const TimeWidget({
    super.key,
    this.time,
    this.style,
    required this.show24hFormat,
    this.amPmStyle,
  });

  /// show time for a specific time using [DateTime]
  TimeWidget.fromDate({
    super.key,
    required DateTime dateTime,
    this.style,
    required this.show24hFormat,
    this.amPmStyle,
  }) : time = TimeOfDay.fromDateTime(dateTime);

  /// show time for a specific time using string
  TimeWidget.fromString({
    super.key,
    this.style,
    required this.show24hFormat,
    this.amPmStyle,
    required String time,
  }) : time = time.toTimeOfDay();

  final TimeOfDay? time;

  final TextStyle? style;

  final bool show24hFormat;
  final TextStyle? amPmStyle;

  @override
  Widget build(BuildContext context) {
    if (time == null) return Text('');

    if (show24hFormat) {
      return Text(
        time!.format(context),
        style: style,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "${time!.hourOfPeriod.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}",
          style: style,
        ),
        SizedBox(width: 2),
        TimePeriodWidget(
          dateTime: time!.toDate(),
          style: amPmStyle,
        ),
      ],
    );
  }
}
