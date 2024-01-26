import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mawaqit/i18n/l10n.dart';

import '../helpers/TimeShiftManager.dart';

class TimePickerModal extends StatelessWidget {
  final TimeShiftManager timeShiftManager;

  TimePickerModal({required this.timeShiftManager});

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
            Navigator.of(context).pop();
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
  final TimeShiftManager timeManager = TimeShiftManager();
  DateTime selectedTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    DateTime selectedTime = DateTime.now().add(Duration(
        hours: timeManager.shift, minutes: timeManager.shiftInMinutes));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          title: Text(
              '${S.of(context).selectedTime} ${_formatTime(selectedTime)}'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => _selectTime(context),
              child: Text(S.of(context).timeSettingDesc),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => _showConfirmationDialog(),
              child: Text(S.of(context).useDeviceTime),
            ),
          ],
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

      widget.onTimeSelected(selectedDateTime);
    }
  }

  String _formatTime(DateTime time) {
    return DateFormat.Hm().format(time);
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.of(context).confirmation),
          content: Text(S.of(context).confirmationMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(S.of(context).cancel),
            ),
            TextButton(
              onPressed: () {
                timeManager.useDeviceTime();
                Navigator.of(context).pop();
              },
              child: Text(S.of(context).ok),
            ),
          ],
        );
      },
    );
  }
}
