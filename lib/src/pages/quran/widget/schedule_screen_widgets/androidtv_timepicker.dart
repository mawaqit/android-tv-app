// The TVFriendlyTimePicker class remains unchanged
import 'package:flutter/material.dart';
import 'package:mawaqit/i18n/l10n.dart';

class TVFriendlyTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final Function(TimeOfDay) onTimeSelected;

  TVFriendlyTimePicker({required this.initialTime, required this.onTimeSelected});

  @override
  _TVFriendlyTimePickerState createState() => _TVFriendlyTimePickerState();
}

class _TVFriendlyTimePickerState extends State<TVFriendlyTimePicker> {
  late int _hour;
  late int _minute;

  @override
  void initState() {
    super.initState();
    _hour = widget.initialTime.hour;
    _minute = widget.initialTime.minute;
  }

  void _updateTime() {
    widget.onTimeSelected(TimeOfDay(hour: _hour, minute: _minute));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).selectTime),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildNumberPicker(_hour, 0, 23, (value) => setState(() => _hour = value)),
              Text(':'),
              _buildNumberPicker(_minute, 0, 59, (value) => setState(() => _minute = value)),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(S.of(context).cancel),
        ),
        ElevatedButton(
          onPressed: _updateTime,
          child: Text(S.of(context).ok),
        ),
      ],
    );
  }

  Widget _buildNumberPicker(int value, int minValue, int maxValue, Function(int) onChanged) {
    return Column(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_drop_up),
          onPressed: () {
            int newValue = value + 1;
            if (newValue > maxValue) newValue = minValue;
            onChanged(newValue);
          },
        ),
        Text(
          value.toString().padLeft(2, '0'),
          style: TextStyle(fontSize: 24),
        ),
        IconButton(
          icon: Icon(Icons.arrow_drop_down),
          onPressed: () {
            int newValue = value - 1;
            if (newValue < minValue) newValue = maxValue;
            onChanged(newValue);
          },
        ),
      ],
    );
  }
}
