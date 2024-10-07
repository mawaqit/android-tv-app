import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SwitchButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double opacity;
  final double iconSize;
  final FocusNode? focusNode;
  final double splashFactorSize;
  final bool isAutofocus;

  const SwitchButton({
    super.key,
    required this.icon,
    required this.opacity,
    required this.onPressed,
    required this.iconSize,
    this.isAutofocus = false,
    this.focusNode,
    this.splashFactorSize = 1.25,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      focusNode: focusNode,
      autofocus: isAutofocus,
      focusColor: Theme.of(context).focusColor,
      onTap: onPressed,
      customBorder: CircleBorder(),
      child: Container(
        padding: EdgeInsets.all(8.sp),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.2),
        ),
        child: Center(
          child: Icon(
            icon,
            color: Colors.white.withOpacity(opacity),
            size: iconSize,
          ),
        ),
      ),
    );
  }
}
