import 'dart:math';

import 'package:flutter/material.dart';

class MawaqitCircleButton extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final double size;
  final Color? color;
  final String? tooltip;
  final FocusNode? focusNode;
  final void Function()? onPressed;

  const MawaqitCircleButton({
    Key? key,
    this.iconSize = 20,
    required this.icon,
    this.focusNode,
    this.size = 24,
    this.onPressed,
    this.color,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.focusColor;

    return CircleAvatar(
      radius: size,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              buttonColor.withOpacity(0.9),
              buttonColor,
            ],
          ),
        ),
        child: FloatingActionButton(
          focusNode: focusNode,
          tooltip: tooltip,
          heroTag: Random.secure().nextInt(2000000),
          highlightElevation: 0,
          mini: true,
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          child: Icon(
            icon,
            textDirection: TextDirection.ltr,
            size: size - 1,
            color: buttonColor,
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
