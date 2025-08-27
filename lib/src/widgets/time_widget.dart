import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
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
    this.fallbackString,
  });

  /// show time for a specific time using [DateTime]
  TimeWidget.fromDate({
    super.key,
    required DateTime dateTime,
    this.style,
    required this.show24hFormat,
    this.amPmStyle,
  })  : time = TimeOfDay.fromDateTime(dateTime),
        fallbackString = null;

  /// show time for a specific time using string
  TimeWidget.fromString({
    super.key,
    this.style,
    required this.show24hFormat,
    this.amPmStyle,
    required String time,
  })  : time = time.toTimeOfDay(),
        fallbackString = time;

  final TimeOfDay? time;
  final String? fallbackString;

  final TextStyle? style;

  final bool show24hFormat;
  final TextStyle? amPmStyle;

  @override
  Widget build(BuildContext context) {
    if (time == null) return Text(fallbackString ?? '', style: style);

    if (show24hFormat) {
      return Text(
        "${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}",
        style: style,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "${time!.hourOfPeriod.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}",
          style: style,
          maxLines: 1,
        ),
        SizedBox(width: 0.3.vw),
        TimePeriodWidget(
          dateTime: time!.toDate(),
          style: amPmStyle ?? style,
        ),
      ],
    );
  }
}
