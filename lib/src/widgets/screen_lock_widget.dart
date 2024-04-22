import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../i18n/l10n.dart';
import '../helpers/AppDate.dart';
import '../helpers/TimeShiftManager.dart';
import '../../../main.dart';
import '../services/mosque_manager.dart';

class ScreenLockModal extends StatelessWidget {
  final TimeShiftManager timeShiftManager;

  ScreenLockModal({required this.timeShiftManager});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xff161b22),
      title: Text("Configure screen lock"),
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
  bool value = false;
  int _selectedMinuteBefore = 10;
  int _selectedMinuteAfter = 10;

  @override
  void initState() {
    super.initState();
    selectedTime = DateTime.now().add(Duration(
        hours: timeManager.shift, minutes: timeManager.shiftInMinutes));
  }

  Future<void> _toggleScreen() async {
    try {
      await MethodChannel('nativeMethodsChannel').invokeMethod('toggleScreen');
    } on PlatformException catch (e) {
      logger.e(e);
    }
  }

  void scheduleToggleScreen(
      List<String> timeStrings, int beforeDelayMinutes, int afterDelayMinutes) {
    for (String timeString in timeStrings) {
      final parts = timeString.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final now = AppDateTime.now();
      final scheduledDateTime =
          DateTime(now.year, now.month, now.day, hour, minute);

      if (scheduledDateTime.isBefore(now)) {
        // Schedule for the next day if the time has already passed
        scheduledDateTime.add(Duration(days: 1));
      }

      // Schedule one minute before
      final beforeDelay = scheduledDateTime.difference(now) -
          Duration(minutes: beforeDelayMinutes);
      if (beforeDelay.isNegative) {
        // Skip scheduling if the delay is negative
        continue;
      }
      Timer(beforeDelay, () {
        _toggleScreen();
      });
      print("Before delay Minutes: $beforeDelayMinutes");
      print("After delay Minutes: $afterDelayMinutes");

      print("Before delay: $beforeDelay");
      print("Before scheduledDateTime: $scheduledDateTime");

      // Schedule one minute after
      final afterDelay = scheduledDateTime.difference(now) +
          Duration(minutes: afterDelayMinutes);
      Timer(afterDelay, () {
        _toggleScreen();
      });
      print("After delay: $afterDelay");
      print("After scheduledDateTime: $scheduledDateTime");
    }
  }

  void _selectNextMinuteBefore() {
    setState(() {
      _selectedMinuteBefore = (_selectedMinuteBefore + 1) % 60;
    });
  }

  void _selectPreviousMinuteBefore() {
    setState(() {
      _selectedMinuteBefore = (_selectedMinuteBefore - 1 + 60) % 60;
    });
  }

  void _selectNextMinuteAfter() {
    setState(() {
      _selectedMinuteAfter = (_selectedMinuteAfter + 1) % 60;
    });
  }

  void _selectPreviousMinuteAfter() {
    setState(() {
      _selectedMinuteAfter = (_selectedMinuteAfter - 1 + 60) % 60;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mosqueProvider = context.watch<MosqueManager>();
    final today = mosqueProvider.useTomorrowTimes
        ? AppDateTime.tomorrow()
        : AppDateTime.now();

    final times =
        mosqueProvider.times!.dayTimesStrings(today, salahOnly: false);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          clipBehavior: Clip.antiAlias,
          child: SwitchListTile(
            autofocus: true,
            secondary: Icon(Icons.monitor, size: 35),
            title: Text("Screen lock mode"),
            subtitle: Text(
              "This feature turn on/off the device before and after each prayer adhan",
              maxLines: 2,
              overflow: TextOverflow.clip,
            ),
            value: value,
            onChanged: (newValue) {
              setState(() {
                value = !value; // Invert the current value
              });
            },
          ),
        ),
        value
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text("Before"),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_upward),
                        onPressed: _selectNextMinuteBefore,
                      ),
                      Text(
                        _selectedMinuteBefore.toString().padLeft(2, '0'),
                        style: TextStyle(fontSize: 24),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_downward),
                        onPressed: _selectPreviousMinuteBefore,
                      ),
                    ],
                  ),
                  Text("After"),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_upward),
                        onPressed: _selectNextMinuteAfter,
                      ),
                      Text(
                        _selectedMinuteAfter.toString().padLeft(2, '0'),
                        style: TextStyle(fontSize: 24),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_downward),
                        onPressed: _selectPreviousMinuteAfter,
                      ),
                    ],
                  ),
                ],
              )
            : SizedBox(),
        value
            ? OutlinedButton(
                onPressed: () => scheduleToggleScreen(
                  times,
                  _selectedMinuteBefore,
                  _selectedMinuteAfter,
                ),
                child: Text(S.current.ok),
              )
            : SizedBox()
      ],
    );
  }
}
