import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/services/toggle_screen_feature_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../i18n/l10n.dart';
import '../helpers/AppDate.dart';
import '../helpers/TimeShiftManager.dart';
import '../services/mosque_manager.dart';

class ScreenLockModal extends StatelessWidget {
  final TimeShiftManager timeShiftManager;

  ScreenLockModal({required this.timeShiftManager});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xff161b22),
      title: Text("Configure screen on/off"),
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
  late SharedPreferences _prefs;

  static const String _minuteBeforeKey = 'selectedMinuteBefore';
  static const String _minuteAfterKey = 'selectedMinuteAfter';
  @override
  void initState() {
    super.initState();
    selectedTime = DateTime.now().add(Duration(
        hours: timeManager.shift, minutes: timeManager.shiftInMinutes));
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      bool isActive = await ToggleScreenFeature.getToggleFeatureState();
      _prefs = await SharedPreferences.getInstance();

      setState(() {
        _selectedMinuteBefore = _prefs.getInt(_minuteBeforeKey) ?? 10;
        _selectedMinuteAfter = _prefs.getInt(_minuteAfterKey) ?? 30;
        value = isActive;
      });
    });
  }

  void _selectNextMinuteBefore() {
    setState(() {
      _selectedMinuteBefore = (_selectedMinuteBefore + 1) % 60;
      if (_selectedMinuteBefore < 10) {
        _selectedMinuteBefore = 10;
      }
    });
  }

  void _selectPreviousMinuteBefore() {
    setState(() {
      _selectedMinuteBefore = (_selectedMinuteBefore - 1 + 60) % 60;
      if (_selectedMinuteBefore < 10) {
        _selectedMinuteBefore = 59;
      }
    });
  }

  void _selectNextMinuteAfter() {
    setState(() {
      _selectedMinuteAfter = (_selectedMinuteAfter + 1) % 60;
      if (_selectedMinuteAfter < 10) {
        _selectedMinuteAfter = 10;
      }
    });
  }

  void _selectPreviousMinuteAfter() {
    setState(() {
      _selectedMinuteAfter = (_selectedMinuteAfter - 1 + 60) % 60;
      if (_selectedMinuteAfter < 10) {
        _selectedMinuteAfter = 59;
      }
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
            value: value,
            onChanged: (newValue) async {
              setState(() {
                value = newValue;
                ToggleScreenFeature.toggleFeatureState(newValue);
              });

              if (!newValue) {
                await ToggleScreenFeature.cancelAllScheduledTimers();
                ToggleScreenFeature.toggleFeatureState(false);
              }
              /*    if (newValue) {
                ToggleScreenFeature.scheduleToggleScreen(
                  times,
                  4,
                  4,
                );
                ToggleScreenFeature.toggleFeatureState(true);
              } */
            },
          ),
        ),
        value
            ? Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Power on the screen',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _MinuteSelector(
                          selectedMinute: _selectedMinuteBefore,
                          onIncrease: _selectNextMinuteBefore,
                          onDecrease: _selectPreviousMinuteBefore,
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '$_selectedMinuteBefore minutes before each prayer time',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Power off the screen',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _MinuteSelector(
                          selectedMinute: _selectedMinuteAfter,
                          onIncrease: _selectNextMinuteAfter,
                          onDecrease: _selectPreviousMinuteAfter,
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '$_selectedMinuteAfter minutes after each prayer time',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              )
            : SizedBox(),
        SizedBox(height: 16),
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
                  _prefs.setInt(_minuteBeforeKey, _selectedMinuteBefore),
                  _prefs.setInt(_minuteAfterKey, _selectedMinuteAfter),
                  Navigator.pop(context)
                },
                child: Text(S.current.ok),
              )
            : SizedBox()
      ],
    );
  }
}

class _MinuteSelector extends StatelessWidget {
  final int selectedMinute;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  _MinuteSelector({
    required this.selectedMinute,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.remove_circle_outline),
          onPressed: onDecrease,
          iconSize: 18,
          splashRadius: 15,
          focusColor: Color.fromARGB(255, 89, 35, 190),
        ),
        Text(
          selectedMinute.toString().padLeft(2, '0'),
          style: TextStyle(fontSize: 24),
        ),
        IconButton(
          iconSize: 18,
          splashRadius: 15,
          icon: Icon(Icons.add_circle_outline),
          onPressed: onIncrease,
          focusColor: Color.fromARGB(255, 89, 35, 190),
        ),
      ],
    );
  }
}
