import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// A reusable toggle button widget that can be used across all onboarding screens
/// with consistent styling and behavior.
class ToggleButtonWidget extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onPressed;
  final String label;
  final TextStyle? textStyle;
  final bool isPortrait;

  const ToggleButtonWidget({
    super.key,
    required this.isSelected,
    required this.onPressed,
    required this.label,
    this.textStyle,
    this.isPortrait = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Dynamic vertical padding based on screen size and orientation
    final verticalPadding = isPortrait ? (screenWidth > 600 ? 1.2.h : 1.0.h) : (screenWidth > 600 ? 1.8.h : 1.5.h);

    // Ensure font size is responsive but has a minimum size
    final effectiveTextStyle = (textStyle ?? TextStyle(fontSize: isPortrait ? 8.sp : 10.sp));

    return isSelected
        ? _buildSelectedButton(theme, verticalPadding, effectiveTextStyle)
        : _buildUnselectedButton(theme, verticalPadding, effectiveTextStyle);
  }

  Widget _buildSelectedButton(
    ThemeData theme,
    double verticalPadding,
    TextStyle textStyle,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        minimumSize: Size(100.w, 0),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: isPortrait ? 1.w : 2.w),
      ),
      child: Text(
        label,
        style: textStyle.copyWith(height: 1.2),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildUnselectedButton(
    ThemeData theme,
    double verticalPadding,
    TextStyle textStyle,
  ) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(
          vertical: verticalPadding,
          horizontal: isPortrait ? 1.w : 2.w,
        ),
        minimumSize: Size(100.w, 0),
      ),
      child: Text(
        label,
        style: textStyle.copyWith(height: 1.2),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}
