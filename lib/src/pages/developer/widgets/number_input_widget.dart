import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberInputScreen extends StatefulWidget {
  const NumberInputScreen({
    Key? key,
    this.children,
    this.wipeDuration = const Duration(seconds: 1),
    this.onNumberInput,
    this.onKeyInput,
  }) : super(key: key);

  final List<Widget>? children;
  final void Function(int value)? onNumberInput;
  final void Function(RawKeyDownEvent event)? onKeyInput;

  /// clear the number after this duration
  final Duration wipeDuration;

  @override
  State<NumberInputScreen> createState() => _NumberInputScreenState();
}

class _NumberInputScreenState extends State<NumberInputScreen> {
  int? currentNumber;

  handleKey(RawKeyDownEvent event) {
    if (int.tryParse(event.logicalKey.keyLabel) != null) {
      setState(() {
        currentNumber ??= 0;
        currentNumber =
            (currentNumber! * 10) + int.parse(event.logicalKey.keyLabel);
      });
    } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
      if (currentNumber == null || currentNumber == 0) return;

      setState(() => currentNumber = (currentNumber! / 10).floor());
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      submitNumber();
    } else {
      widget.onKeyInput?.call(event);
    }

    EasyDebounce.debounce(
      'Submit-Key',
      widget.wipeDuration,
      submitNumber,
    );
  }

  clearNumber() {
    setState(() {
      currentNumber = null;
    });
  }

  submitNumber() {
    if (currentNumber == null) return;

    widget.onNumberInput?.call(currentNumber!);
    clearNumber();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKey: (event) {
        if (event is! RawKeyDownEvent) return;

        handleKey(event);
      },
      child: Stack(
        children: [
          if (widget.children != null) ...widget.children!,
          numberWidget(),
        ],
      ),
    );
  }

  Widget numberWidget() {
    if (currentNumber == null) return const SizedBox();

    return Align(
      alignment: Alignment.topRight,
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.white38),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          currentNumber.toString(),
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }
}
