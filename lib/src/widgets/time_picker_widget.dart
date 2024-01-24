import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mawaqit/i18n/l10n.dart';

import '../helpers/TimeShiftManager.dart';

class TimePickerDialogg extends StatelessWidget {
  final TimeShiftManager timeShiftManager;

  TimePickerDialogg({required this.timeShiftManager});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).timeSetting),
      content: TimePicker(onTimeSelected: (selectedTime) {
        timeShiftManager.adjustTimeFromTimePicker(selectedTime);
      }),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text(S.of(context).ok),
        ),
      ],
    );
  }
}

class TimePicker extends StatefulWidget {
  final Function(DateTime) onTimeSelected;

  TimePicker({required this.onTimeSelected});

  @override
  _TimePickerState createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  DateTime selectedTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          title: Text(
              '${S.of(context).selectedTime} ${_formatTime(selectedTime)}'),
        ),
        ElevatedButton(
          onPressed: () => _selectTime(context),
          child: Text(S.of(context).timeSettingDesc),
        ),
      ],
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedTime),
    );

    if (picked != null) {
      DateTime selectedDateTime = DateTime(
        selectedTime.year,
        selectedTime.month,
        selectedTime.day,
        picked.hour,
        picked.minute,
      );

      setState(() {
        selectedTime = selectedDateTime;
      });

      // Call the callback to inform the parent about the selected time
      widget.onTimeSelected(selectedDateTime);
    }
  }

  String _formatTime(DateTime time) {
    return DateFormat.Hm().format(time);
  }
}
