import 'package:flutter/material.dart';

class FocusableTimePicker extends StatefulWidget {
  final String label;
  final TimeOfDay time;
  final bool isStartTime;
  final Function(BuildContext, bool) onTap;

  FocusableTimePicker({
    required this.label,
    required this.time,
    required this.isStartTime,
    required this.onTap,
  });

  @override
  _FocusableTimePickerState createState() => _FocusableTimePickerState();
}

class _FocusableTimePickerState extends State<FocusableTimePicker> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (ActivateIntent intent) {
            widget.onTap(context, widget.isStartTime);
            return null;
          },
        ),
      },
      child: InkWell(
        onTap: () => widget.onTap(context, widget.isStartTime),
        child: Container(
          decoration: BoxDecoration(
            color: _isFocused ? Theme.of(context).primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            title: Text(
              widget.label,
              style: TextStyle(color: _isFocused ? Colors.white : null),
            ),
            trailing: Text(
              widget.time.format(context),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _isFocused ? Colors.white : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
