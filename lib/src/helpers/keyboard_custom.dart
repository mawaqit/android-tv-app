import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

enum KeyboardType {
  numeric,
  alphanumeric,
}

class KeyboardCustom extends StatefulWidget {
  const KeyboardCustom({
    Key? key,
    this.keyboardType = KeyboardType.alphanumeric,
    required this.controller,
    required this.applyMask,
    this.fontColor = const Color(0xffDADCE0),
    this.fontSize = 20.0,
    this.iconColor = Colors.white,
    this.iconSize = 25,
    this.buttonColor = const Color(0xff2A3139),
    this.backgroundColor = const Color(0xff191C22),
    this.alphanumericHeight = 0.06,
    this.numericHeight = 0.075,
    this.onSubmit, // Add this line
  }) : super(key: key);
  final void Function(String)? onSubmit; // Add this line

  final KeyboardType keyboardType;
  final TextEditingController controller;
  final String Function(String) applyMask;
  final Color fontColor;
  final double fontSize;
  final Color iconColor;
  final double iconSize;
  final Color buttonColor;
  final Color backgroundColor;
  final double alphanumericHeight;
  final double numericHeight;

  @override
  State<KeyboardCustom> createState() => _KeyboardCustomState();
}

class _KeyboardCustomState extends State<KeyboardCustom> {
  bool _shiftEnabled = false;
  final FocusNode _focusNode = FocusNode();
  late Timer _backspaceTimer;
  late LongPressGestureRecognizer _backspaceLongPressRecognizer;

  @override
  void initState() {
    super.initState();
    _backspaceTimer = Timer(Duration.zero, () {});
    _backspaceLongPressRecognizer = LongPressGestureRecognizer()
      ..onLongPressStart = _startBackspaceTimer
      ..onLongPressEnd = _stopBackspaceTimer;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _backspaceTimer.cancel();
    _backspaceLongPressRecognizer.dispose();
    super.dispose();
  }

  void _startBackspaceTimer(LongPressStartDetails details) {
    _backspaceTimer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (widget.controller.text.isNotEmpty) {
        setState(() {
          widget.controller.text = widget.controller.text.substring(0, widget.controller.text.length - 1);
        });
      }
    });
  }

  void _stopBackspaceTimer(LongPressEndDetails details) {
    _backspaceTimer.cancel();
  }

  Widget buildButton(String tecla) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            String valorAtual = widget.controller.text;
            String valorNovo = _shiftEnabled ? tecla.toUpperCase() : tecla.toLowerCase();
            String valorAtualizado = widget.applyMask(valorAtual + valorNovo);
            widget.controller.text = valorAtualizado;
          });
          _focusNode.requestFocus();
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.grey.shade300,
          disabledBackgroundColor: Colors.grey.shade400,
          backgroundColor: widget.buttonColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
            side: const BorderSide(color: Colors.black, width: 0.25),
          ),
        ),
        child: Container(
          alignment: Alignment.center,
          child: Text(
            _shiftEnabled ? tecla.toUpperCase() : tecla.toLowerCase(),
            style: TextStyle(fontSize: widget.fontSize, color: widget.fontColor),
          ),
        ),
      ),
    );
  }

  Widget buildButtonCustom(IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: GestureDetector(
        onLongPressStart: _startBackspaceTimer,
        onLongPressEnd: _stopBackspaceTimer,
        child: ElevatedButton(
          onPressed: () {
            if (icon == Icons.backspace) {
              if (widget.controller.text.isNotEmpty) {
                widget.controller.text = widget.controller.text.substring(0, widget.controller.text.length - 1);
              }
            }
            if (icon == Icons.arrow_forward) {
              // Call the onSubmit callback with the current text value
              widget.onSubmit?.call(widget.controller.text);
            }
            if (icon == Icons.arrow_upward) {
              setState(() {
                _shiftEnabled = !_shiftEnabled;
              });
            }
            if (icon == Icons.space_bar) {
              if (widget.controller.text.isNotEmpty) {
                widget.controller.text += ' ';
              }
            }
            _focusNode.requestFocus();
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.grey.shade300,
            disabledBackgroundColor: Colors.grey.shade400,
            backgroundColor: widget.buttonColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
              side: const BorderSide(color: Colors.black, width: 0.25),
            ),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: widget.iconSize,
              color: widget.iconColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBackSpaceCustom(IconData icon) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(2),
      child: SizedBox(
        height: size.height,
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              widget.controller.text += ' ';
            });
            _focusNode.requestFocus();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.buttonColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
              side: const BorderSide(color: Colors.black, width: 0.25),
            ),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: widget.iconSize,
              color: widget.iconColor,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SizedBox(
      child: SingleChildScrollView(
        child: widget.keyboardType == KeyboardType.alphanumeric
            ? Container(
                padding: const EdgeInsets.all(5),
                width: 450,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: widget.backgroundColor,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: size.height * widget.alphanumericHeight,
                      child: Row(
                        children: [
                          Flexible(child: buildButton('1')),
                          Flexible(child: buildButton('2')),
                          Flexible(child: buildButton('3')),
                          Flexible(child: buildButton('4')),
                          Flexible(child: buildButton('5')),
                          Flexible(child: buildButton('6')),
                          Flexible(child: buildButton('7')),
                          Flexible(child: buildButton('8')),
                          Flexible(child: buildButton('9')),
                          Flexible(child: buildButton('0')),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: size.height * widget.alphanumericHeight,
                      child: Row(
                        children: [
                          Flexible(child: buildButton('q')),
                          Flexible(child: buildButton('w')),
                          Flexible(child: buildButton('e')),
                          Flexible(child: buildButton('r')),
                          Flexible(child: buildButton('t')),
                          Flexible(child: buildButton('y')),
                          Flexible(child: buildButton('u')),
                          Flexible(child: buildButton('i')),
                          Flexible(child: buildButton('o')),
                          Flexible(child: buildButton('p')),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: size.height * widget.alphanumericHeight,
                      child: Row(
                        children: [
                          Flexible(child: buildButton('a')),
                          Flexible(child: buildButton('s')),
                          Flexible(child: buildButton('d')),
                          Flexible(child: buildButton('f')),
                          Flexible(child: buildButton('g')),
                          Flexible(child: buildButton('h')),
                          Flexible(child: buildButton('j')),
                          Flexible(child: buildButton('k')),
                          Flexible(child: buildButton('l')),
                          Flexible(child: buildButton('@')),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: size.height * widget.alphanumericHeight,
                      child: Row(
                        children: [
                          Flexible(child: buildButtonCustom(Icons.arrow_upward)),
                          Flexible(child: buildButton('z')),
                          Flexible(child: buildButton('x')),
                          Flexible(child: buildButton('c')),
                          Flexible(child: buildButton('v')),
                          Flexible(child: buildButton('b')),
                          Flexible(child: buildButton('n')),
                          Flexible(child: buildButton('m')),
                          Flexible(child: buildButton('.')),
                          Flexible(child: buildButtonCustom(Icons.backspace)),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: size.height * widget.alphanumericHeight,
                      child: Row(
                        children: [
                          Flexible(child: buildButton('&')),
                          Flexible(child: buildButton('#')),
                          Flexible(child: buildButton('!')),
                          SizedBox(
                            width: size.width * 0.15,
                            child: buildBackSpaceCustom(Icons.space_bar),
                          ),
                          Flexible(child: buildButton('-')),
                          Flexible(child: buildButton('_')),
                          SizedBox(
                            width: size.width * 0.10,
                            child: buildButtonCustom(Icons.arrow_forward),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                width: 450,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: widget.backgroundColor,
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    SizedBox(
                      height: size.height * widget.numericHeight,
                      child: Row(
                        children: [
                          Flexible(child: buildButton('1')),
                          Flexible(child: buildButton('2')),
                          Flexible(child: buildButton('3')),
                          Flexible(child: buildButton('-')),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: size.height * widget.numericHeight,
                      child: Row(
                        children: [
                          Flexible(child: buildButton('4')),
                          Flexible(child: buildButton('5')),
                          Flexible(child: buildButton('6')),
                          Flexible(child: buildButtonCustom(Icons.space_bar)),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: size.height * widget.numericHeight,
                      child: Row(
                        children: [
                          Flexible(child: buildButton('7')),
                          Flexible(child: buildButton('8')),
                          Flexible(child: buildButton('9')),
                          Flexible(child: buildButtonCustom(Icons.backspace)),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: size.height * widget.numericHeight,
                      child: Row(
                        children: [
                          Flexible(child: buildButton('.')),
                          Flexible(child: buildButton('0')),
                          Flexible(child: buildButton(',')),
                          Flexible(
                            child: buildButtonCustom(Icons.arrow_forward),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
