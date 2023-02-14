import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FadeInOutWidget extends StatefulWidget {
  const FadeInOutWidget({
    Key? key,
    required this.first,
    required this.duration,
    required this.second,
    this.secondDuration,
    this.disableSecond = false,
  }) : super(key: key);

  final Widget first;
  final Duration duration;
  final Widget second;
  final Duration? secondDuration;
  final bool disableSecond;

  @override
  State<FadeInOutWidget> createState() => _FadeInOutWidgetState();
}

class _FadeInOutWidgetState extends State<FadeInOutWidget> {
  bool _showSecond = false;

  @override
  void initState() {
    Future.delayed(widget.duration, showNextItem);

    print('FadeInOutWidget: initState()');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        alignment: Alignment.center,
        children: [
          widget.first
              .animate(target: _showSecond ? 0 : 1)
              .fadeIn()
              .fade(duration: 1.seconds),
          widget.second
              .animate(target: _showSecond ? 1 : 0)
              .fadeIn()
              .fade(begin: 200, duration: 1.seconds),
        ],
      ),
    );
  }

  void showNextItem() {
    if (!mounted) return;

    setState(() => _showSecond = !_showSecond && !widget.disableSecond);

    final nextDuration = _showSecond
        ? widget.secondDuration ?? widget.duration
        : widget.duration;

    Future.delayed(nextDuration, showNextItem);
  }
}
