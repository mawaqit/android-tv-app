import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/services/toggle_screen_feature_manager.dart';
import 'package:mawaqit/src/state_management/screen_lock/screen_lock_notifier.dart';
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

class _TimePicker extends ConsumerStatefulWidget {
  final Function(DateTime) onTimeSelected;

  _TimePicker({required this.onTimeSelected});

  @override
  __TimePickerState createState() => __TimePickerState();
}

class __TimePickerState extends ConsumerState<_TimePicker> {
  final TimeShiftManager timeManager = TimeShiftManager();
  late DateTime selectedTime;
  bool value = false;

  @override
  void initState() {
    super.initState();
    selectedTime = DateTime.now().add(Duration(hours: timeManager.shift, minutes: timeManager.shiftInMinutes));
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(screenLockNotifierProvider.notifier);
      value = await ToggleScreenFeature.getToggleFeatureState();
      setState(() {
        value = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final mosqueProvider = context.watch<MosqueManager>();
    final today = mosqueProvider.useTomorrowTimes ? AppDateTime.tomorrow() : AppDateTime.now();
    final times = mosqueProvider.times?.dayTimesStrings(today, salahOnly: false) ?? [];

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
    int selectedMinuteBefore = ref.watch(screenLockNotifierProvider).maybeWhen(
          orElse: () => 10,
          data: (data) => data.selectedMinuteBefore,
        );
    int selectedMinuteAfter = ref.watch(screenLockNotifierProvider).maybeWhen(
          orElse: () => 10,
          data: (data) => data.selectedMinuteAfter,
        );
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
            selectedMinuteBefore,
            ref.read(screenLockNotifierProvider.notifier).selectNextMinuteBefore,
            ref.read(screenLockNotifierProvider.notifier).selectPreviousMinuteBefore,
            S.of(context).before,
          ),
          const SizedBox(height: 16),
          _buildTimeSelector(
            context,
            S.of(context).powerOffScreen,
            selectedMinuteAfter,
            ref.read(screenLockNotifierProvider.notifier).selectNextMinuteAfter,
            ref.read(screenLockNotifierProvider.notifier).selectPreviousMinuteAfter,
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
    void Function(int) onIncrease,
    void Function(int) onDecrease,
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
              onIncrease: () => onIncrease(selectedMinute),
              onDecrease: () => onDecrease(selectedMinute),
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
        await ref.read(screenLockNotifierProvider.notifier).saveSettings(times);
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
