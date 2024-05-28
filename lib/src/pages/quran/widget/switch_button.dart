import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SwitchButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double opacity;

  const SwitchButton({
    super.key,
    required this.icon,
    required this.opacity,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 10.w, // Set the desired width
        height: 10.w, // Set the desired height
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(opacity),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            icon,
            color: Colors.white,
            size: 18.sp,
          ),
        ),
      ),
    );
  }
}
