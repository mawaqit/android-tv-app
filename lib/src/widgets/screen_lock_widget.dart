import 'dart:async';
import 'package:flutter/material.dart';
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
      backgroundColor: const Color(0xff161b22),
      title: Text(S.of(context).screenLockConfig),
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
    selectedTime = DateTime.now().add(Duration(hours: timeManager.shift, minutes: timeManager.shiftInMinutes));
    _initializePreferences();
  }

  Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
    bool isActive = await ToggleScreenFeature.getToggleFeatureState();

    setState(() {
      _selectedMinuteBefore = _prefs.getInt(_minuteBeforeKey) ?? 10;
      _selectedMinuteAfter = _prefs.getInt(_minuteAfterKey) ?? 30;
      value = isActive;
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
    final today = mosqueProvider.useTomorrowTimes ? AppDateTime.tomorrow() : AppDateTime.now();
    final times =
        mosqueProvider.times?.dayTimesStrings(today, salahOnly: false) ?? [];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildToggleSwitch(context),
        if (value) _buildTimeConfiguration(context, times),
        SizedBox(height: 16),
        if (value) _buildSaveButton(context, times),
      ],
    );
  }

  Widget _buildToggleSwitch(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      clipBehavior: Clip.antiAlias,
      child: SwitchListTile(
        autofocus: true,
        secondary: const Icon(Icons.monitor, size: 35),
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
        },
      ),
    );
  }

  Widget _buildTimeConfiguration(BuildContext context, List<String> times) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        children: [
          _buildTimeSelector(
            context,
            S.of(context).powerOnScreen,
            _selectedMinuteBefore,
            _selectNextMinuteBefore,
            _selectPreviousMinuteBefore,
            S.of(context).before,
          ),
          const SizedBox(height: 16),
          _buildTimeSelector(
            context,
            S.of(context).powerOffScreen,
            _selectedMinuteAfter,
            _selectNextMinuteAfter,
            _selectPreviousMinuteAfter,
            S.of(context).after,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector(
    BuildContext context,
    String label,
    int selectedMinute,
    VoidCallback onIncrease,
    VoidCallback onDecrease,
    String suffix,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _MinuteSelector(
              selectedMinute: selectedMinute,
              onIncrease: onIncrease,
              onDecrease: onDecrease,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '$selectedMinute $suffix',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, List<String> times) {
    return OutlinedButton(
      onPressed: () async {
        await ToggleScreenFeature.cancelAllScheduledTimers();
        ToggleScreenFeature.toggleFeatureState(false);
        ToggleScreenFeature.scheduleToggleScreen(
          times,
          _selectedMinuteBefore,
          _selectedMinuteAfter,
        );
        ToggleScreenFeature.toggleFeatureState(true);
        _prefs.setInt(_minuteBeforeKey, _selectedMinuteBefore);
        _prefs.setInt(_minuteAfterKey, _selectedMinuteAfter);
        Navigator.pop(context);
      },
      child: Text(S.current.ok),
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
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: onDecrease,
          iconSize: 18,
          splashRadius: 15,
          focusColor: const Color.fromARGB(255, 89, 35, 190),
        ),
        Text(
          selectedMinute.toString().padLeft(2, '0'),
          style: const TextStyle(fontSize: 24),
        ),
        IconButton(
          iconSize: 18,
          splashRadius: 15,
          icon: const Icon(Icons.add_circle_outline),
          onPressed: onIncrease,
          focusColor: const Color.fromARGB(255, 89, 35, 190),
        ),
      ],
    );
  }
}
