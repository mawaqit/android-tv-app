import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:sizer/sizer.dart';

class TimePeriodWidget extends StatelessWidget {
  const TimePeriodWidget({
    Key? key,
    required this.dateTime,
    this.style,
  }) : super(key: key);

  final DateTime dateTime;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final value = DateFormat(
      "a",
      Localizations.localeOf(context).languageCode,
    ).format(dateTime);

    final defaultStyle = DefaultTextStyle.of(context).style;
    final textStyle = (style ?? defaultStyle).copyWith(
      height: 1,
    );

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 4.3.w),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          value,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: textStyle,
        ),
      ),
    );
  }
}
