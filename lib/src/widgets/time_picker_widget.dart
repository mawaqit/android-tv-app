import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../i18n/l10n.dart';
import '../helpers/TimeShiftManager.dart';

class TimePickerModal extends StatelessWidget {
  final TimeShiftManager timeShiftManager;

  TimePickerModal({required this.timeShiftManager});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xff161b22),
      title: Text(S.of(context).timeSetting),
      content: _TimePicker(
        onTimeSelected: (selectedTime) {
          timeShiftManager.adjustTimeFromTimePicker(selectedTime);
        },
      ),
    );
  }
}

class _TimePicker extends StatefulWidget {
  final Function(DateTime) onTimeSelected;

  _TimePicker({required this.onTimeSelected});

  @override
  __TimePickerState createState() => __TimePickerState();
}

class __TimePickerState extends State<_TimePicker> {
  final TimeShiftManager timeManager = TimeShiftManager();
  late DateTime selectedTime;

  @override
  void initState() {
    super.initState();
    selectedTime = DateTime.now().add(Duration(
        hours: timeManager.shift, minutes: timeManager.shiftInMinutes));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          title: Text(
            '${S.of(context).selectedTime} ${_formatTime(selectedTime)}',
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            OutlinedButton(
              autofocus: true,
              onPressed: () => _selectTime(context),
              child: Text(S.of(context).timeSettingDesc),
            ),
            SizedBox(width: 10),
            OutlinedButton(
              onPressed: () => _showConfirmationDialog(),
              child: Text(S.of(context).useDeviceTime),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    await showDialog<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        return _DPadTimePicker(
          onTimeSelected: (selectedTime) {
            _handleSelectedTime(selectedTime);
          },
        );
      },
    );
  }

  void _handleSelectedTime(DateTime selectedTimeOfDay) {
    final newDateTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      selectedTimeOfDay.hour,
      selectedTimeOfDay.minute,
    );

    setState(() {
      selectedTime = newDateTime;
    });

    widget.onTimeSelected(newDateTime);
  }

  String _formatTime(DateTime time) {
    return DateFormat.Hm().format(time);
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xff161b22),
          title: Text(S.of(context).confirmation),
          content: Text(S.of(context).confirmationMessage),
          actions: <Widget>[
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(S.of(context).cancel),
            ),
            OutlinedButton(
              autofocus: true,
              onPressed: () {
                timeManager.useDeviceTime();
                setState(() {
                  selectedTime = DateTime.now();
                });
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

class _DPadTimePicker extends StatefulWidget {
  final void Function(DateTime)? onTimeSelected;

  _DPadTimePicker({Key? key, this.onTimeSelected}) : super(key: key);

  @override
  _DPadTimePickerState createState() => _DPadTimePickerState();
}

class _DPadTimePickerState extends State<_DPadTimePicker> {
  late int _selectedHour;
  late int _selectedMinute;

  @override
  void initState() {
    super.initState();
    final now = TimeOfDay.now();
    _selectedHour = now.hour;
    _selectedMinute = now.minute;
  }

  void _selectNextHour() {
    setState(() {
      _selectedHour = (_selectedHour + 1) % 24;
    });
  }

  void _selectPreviousHour() {
    setState(() {
      _selectedHour = (_selectedHour - 1 + 24) % 24;
    });
  }

  void _selectNextMinute() {
    setState(() {
      _selectedMinute = (_selectedMinute + 1) % 60;
    });
  }

  void _selectPreviousMinute() {
    setState(() {
      _selectedMinute = (_selectedMinute - 1 + 60) % 60;
    });
  }

  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xff161b22),
      contentPadding: EdgeInsets.all(16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            S.of(context).selectTime,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_upward),
                    onPressed: _selectNextHour,
                  ),
                  Text(
                    _selectedHour.toString().padLeft(2, '0'),
                    style: TextStyle(fontSize: 24),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_downward),
                    onPressed: _selectPreviousHour,
                  ),
                ],
              ),
              SizedBox(width: 25),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    ":",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(width: 25),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_upward),
                    onPressed: _selectNextMinute,
                  ),
                  Text(
                    _selectedMinute.toString().padLeft(2, '0'),
                    style: TextStyle(fontSize: 24),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_downward),
                    onPressed: _selectPreviousMinute,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16), // Add spacing between selectors and buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(S.of(context).cancel),
              ),
              SizedBox(width: 16),
              OutlinedButton(
                onPressed: () {
                  final selectedDateTime = DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day,
                    _selectedHour,
                    _selectedMinute,
                  );
                  widget.onTimeSelected?.call(selectedDateTime);

                  Navigator.of(context).pop();
                },
                child: Text(S.of(context).ok),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
