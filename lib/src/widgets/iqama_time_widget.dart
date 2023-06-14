import 'package:flutter/material.dart';
import 'package:mawaqit/src/widgets/time_widget.dart';

class IqamaTimeWidget extends StatelessWidget {
  const IqamaTimeWidget({
    Key? key,
    required this.time,
    this.style,
    this.show24hFormat = false,
  }) : super(key: key);

  final String time;
  final TextStyle? style;

  final bool show24hFormat;

  @override
  Widget build(BuildContext context) {
    if (int.tryParse(time) != null) {
      return Text(time, style: style);
    }

    return TimeWidget.fromString(
      show24hFormat: show24hFormat,
      time: time,
      style: style,
    );
  }
}
