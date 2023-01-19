import 'dart:math';

import 'package:flutter/material.dart';

class MawaqitCircleButton extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final double size;
  final Color color;
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
    this.color = const Color(0xFF490094),
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(73, 0, 148, 1),
              Color(0xFF490094),
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
            color: color,
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
