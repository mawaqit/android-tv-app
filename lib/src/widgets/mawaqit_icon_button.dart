import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class MawaqitIconButton extends StatefulWidget {
  const MawaqitIconButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.focusNode,
    this.isAutoFocus = false,
    this.onPressed,
  }) : super(key: key);
  final IconData icon;
  final FocusNode focusNode;
  final String label;
  final VoidCallback? onPressed;
  final bool isAutoFocus;
  @override
  State<MawaqitIconButton> createState() => _MawaqitIconButtonState();
}

class _MawaqitIconButtonState extends State<MawaqitIconButton> {
  bool focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onPrimary;

    return SizedBox(
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(200)),
        color: focused ? theme.focusColor : theme.colorScheme.primary,
        elevation: 0,
        child: Focus(
          onFocusChange: (value) => setState(() => focused = value),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              focusNode: widget.focusNode,
              onTap: widget.onPressed,
              autofocus: widget.isAutoFocus,
              borderRadius: BorderRadius.circular(200),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                child: Row(
                  children: [
                    Text(
                      widget.label,
                      style: theme.textTheme.bodyLarge!.copyWith(
                        color: focused ? Colors.white : color,
                        fontWeight: FontWeight.w700,
                        fontSize: 10.sp,
                      ),
                    ),
                    SizedBox(width: 12),
                    Icon(
                      widget.icon,
                      color: focused ? Colors.white : color,
                      size: 10.sp,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
