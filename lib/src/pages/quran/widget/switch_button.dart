import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SwitchButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double opacity;
  final double iconSize;

  const SwitchButton({
    super.key,
    required this.icon,
    required this.opacity,
    required this.onPressed,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: Colors.black.withOpacity(opacity),
        size: iconSize,
      ),
    );
  }
}
