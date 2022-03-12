import 'dart:math';

import 'package:flutter/material.dart';

class MawaqitCircleButton extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final double size;
  final Color color;
  final String? tooltip;
  final void Function()? onPressed;

  const MawaqitCircleButton({
    Key? key,
    this.iconSize = 20,
    required this.icon,
    this.size = 24,
    this.onPressed,
    this.color = const Color(0xFF4E2B81),
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
              Color.fromRGBO(200, 126, 201, 1),
              Color(0xFF4E2B81),
            ],
          ),
        ),
        child: FloatingActionButton(
          tooltip: tooltip,
          heroTag: Random.secure().nextInt(2000000),
          highlightElevation: 0,
          mini: true,
          elevation: 0,
          backgroundColor: Theme.of(context).colorScheme.background,
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
