import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mawaqit/src/services/toggle_screen_feature_manager.dart';
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
  bool value = true;
  int _selectedMinuteBefore = 10;
  int _selectedMinuteAfter = 10;

  @override
  void initState() {
    super.initState();
    selectedTime = DateTime.now().add(Duration(
        hours: timeManager.shift, minutes: timeManager.shiftInMinutes));
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool isActive = await ToggleScreenFeature.getToggleFeatureState();

      setState(() {
        value = isActive;
      });
      print("is activated $value");
    });
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
            title: Text(S.of(context).screenLockMode),
            subtitle: Text(
              S.of(context).screenLockDesc2,
              maxLines: 2,
              overflow: TextOverflow.clip,
            ),
            value: value,
            onChanged: (newValue) async {
              setState(() {
                value = newValue; // Update the value
                ToggleScreenFeature.toggleFeatureState(newValue);
              });

              // Check if newValue is false, then cancel all scheduled timers
              if (!newValue) {
                await ToggleScreenFeature.cancelAllScheduledTimers();
                ToggleScreenFeature.toggleFeatureState(false);
              }
              // Check if newValue is true, then create all scheduled timers
              if (newValue) {
                ToggleScreenFeature.scheduleToggleScreen(
                  times,
                  10,
                  10,
                );
                ToggleScreenFeature.toggleFeatureState(true);
              }
            },
          ),
        ),
        value
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(S.of(context).before),
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
                  Text(S.of(context).after),
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
                onPressed: () async => {
                  await ToggleScreenFeature.cancelAllScheduledTimers(),
                  ToggleScreenFeature.toggleFeatureState(false),
                  ToggleScreenFeature.scheduleToggleScreen(
                    times,
                    _selectedMinuteBefore,
                    _selectedMinuteAfter,
                  ),
                  ToggleScreenFeature.toggleFeatureState(true),
                },
                child: Text(S.current.ok),
              )
            : SizedBox()
      ],
    );
  }
}
