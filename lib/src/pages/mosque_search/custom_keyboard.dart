import 'package:flutter/material.dart';

class CustomKeyboardWidget extends StatefulWidget {
  final TextEditingController controller;

  CustomKeyboardWidget({required this.controller});

  @override
  _CustomKeyboardWidgetState createState() => _CustomKeyboardWidgetState();
}

class _CustomKeyboardWidgetState extends State<CustomKeyboardWidget> {
  void _onKeyPressed(String key) {
    if (key == 'Delete') {
      if (widget.controller.text.isNotEmpty) {
        widget.controller.text = widget.controller.text.substring(0, widget.controller.text.length - 1);
      }
    } else if (key == 'Done') {
      return;
    } else {
      widget.controller.text += key;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          child: GridView.count(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            crossAxisCount: 3,
            childAspectRatio: 4,
            children: [
              _buildKeyboardButton('1'),
              _buildKeyboardButton('2'),
              _buildKeyboardButton('3'),
              _buildKeyboardButton('4'),
              _buildKeyboardButton('5'),
              _buildKeyboardButton('6'),
              _buildKeyboardButton('7'),
              _buildKeyboardButton('8'),
              _buildKeyboardButton('9'),
              _buildKeyboardButton('Delete'),
              _buildKeyboardButton('0'),
              _buildKeyboardButton('Done'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyboardButton(String key) {
    return InkWell(
      onTap: () {
        _onKeyPressed(key);
        if (key == 'Done') {
          Navigator.pop(context);
        }
      },
      child: Center(
        child: Text(
          key,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.03,
          ),
        ),
      ),
    );
  }
}
