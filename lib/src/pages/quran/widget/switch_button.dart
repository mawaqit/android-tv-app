import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SwitchButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double opacity;
  final double iconSize;
  final FocusNode? focusNode;
  final double splashFactorSize;

  const SwitchButton({
    super.key,
    required this.icon,
    required this.opacity,
    required this.onPressed,
    required this.iconSize,
    this.focusNode,
    this.splashFactorSize = 1.25,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      focusNode: focusNode,
      onPressed: onPressed,
      splashRadius: iconSize * splashFactorSize,
      icon: Icon(
        icon,
        color: Colors.black.withOpacity(opacity),
        size: iconSize,
      ),
    );
  }
}
